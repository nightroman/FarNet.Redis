using StackExchange.Redis;
using System.Text.Encodings.Web;
using System.Text.Json;

namespace FarNet.Redis.Commands;

public sealed class ExportJson : BaseDBCommand
{
    public const string KeyBlob = "Blob";
    public const string KeyText = "Text";
    public const string KeyHash = "Hash";
    public const string KeyList = "List";
    public const string KeySet = "Set";
    public const string KeyEol = "EOL";

    // required
    public required Stream Stream { get; init; }
    public required IEnumerable<RedisKey> Keys { get; init; }

    // optional
    public TimeSpan? TimeToLive { get; init; }
    public bool FormatAsObjects { get; init; }
    public Action<string>? WriteWarning { get; init; }

    static void WriteBlobOrText(Utf8JsonWriter writer, RedisValue value)
    {
        var obj = AboutRedis.GetBlobOrText(value);
        if (obj is string text)
        {
            writer.WriteString(KeyText, text);
        }
        else
        {
            writer.WriteBase64String(KeyBlob, (byte[])obj);
        }
    }

    static void WriteString(Utf8JsonWriter writer, RedisValue value, bool isList = false)
    {
        var obj = AboutRedis.GetBlobOrText(value);
        if (obj is string text)
        {
            writer.WriteStringValue(text);
        }
        else
        {
            var base64 = Convert.ToBase64String((byte[])obj);
            var json = isList ? $"{Environment.NewLine}      [\"{base64}\"]" : $"[\"{base64}\"]";
            writer.WriteRawValue(json, true);
        }
    }

    static void WriteEndOfLife(Utf8JsonWriter writer, TimeSpan? ttl)
    {
        if (ttl.HasValue)
            writer.WriteString(KeyEol, (DateTime.UtcNow + ttl.Value).ToString("yyyy-MM-dd HH:mm"));
    }

    void WriteValue(Utf8JsonWriter writer, RedisKey key, RedisType type, TimeSpan? ttl)
    {
        switch (type)
        {
            case RedisType.String:
                {
                    RedisValue res = Database.StringGet(key);
                    if (res.IsNull)
                        return;

                    writer.WritePropertyName(key!);

                    if (FormatAsObjects || ttl.HasValue)
                    {
                        writer.WriteStartObject();

                        if (ttl.HasValue)
                            WriteEndOfLife(writer, ttl);

                        WriteBlobOrText(writer, res);

                        writer.WriteEndObject();
                    }
                    else
                    {
                        WriteString(writer, res);
                    }
                }
                return;
            case RedisType.Hash:
                {
                    HashEntry[] res = Database.HashGetAll(key);
                    if (res.Length == 0)
                        return;

                    long[] ttls = Database.HashFieldGetTimeToLive(key, res.Select(x => x.Name).ToArray());

                    writer.WritePropertyName(key!);
                    writer.WriteStartObject();
                    WriteEndOfLife(writer, ttl);

                    writer.WritePropertyName(KeyHash);
                    writer.WriteStartObject();
                    for (int i = 0; i < res.Length; ++i)
                    {
                        // TTL? skip not needed or to be expired
                        var ttl2 = ttls[i];
                        if (ttl2 > 0 && (!TimeToLive.HasValue || ttl2 < TimeToLive.Value.TotalMilliseconds))
                            continue;

                        HashEntry entry = res[i];

                        var field = entry.Name.ToString();
                        writer.WritePropertyName(field);

                        if (ttl2 > 0)
                        {
                            writer.WriteStartObject();
                            WriteEndOfLife(writer, TimeSpan.FromMilliseconds(ttl2));

                            WriteBlobOrText(writer, entry.Value);

                            writer.WriteEndObject();
                        }
                        else
                        {
                            WriteString(writer, entry.Value);
                        }
                    }
                    writer.WriteEndObject();

                    writer.WriteEndObject();
                }
                return;
            case RedisType.List:
                {
                    RedisValue[] res = Database.ListRange(key);
                    if (res.Length == 0)
                        return;

                    writer.WritePropertyName(key!);
                    writer.WriteStartObject();
                    WriteEndOfLife(writer, ttl);

                    writer.WritePropertyName(KeyList);
                    writer.WriteStartArray();
                    foreach (RedisValue item in res)
                        WriteString(writer, item, true);
                    writer.WriteEndArray();

                    writer.WriteEndObject();
                }
                return;
            case RedisType.Set:
                {
                    RedisValue[] res = Database.SetMembers(key);
                    if (res.Length == 0)
                        return;

                    writer.WritePropertyName(key!);
                    writer.WriteStartObject();
                    WriteEndOfLife(writer, ttl);

                    writer.WritePropertyName(KeySet);
                    writer.WriteStartArray();
                    foreach (RedisValue item in res)
                        WriteString(writer, item, true);
                    writer.WriteEndArray();

                    writer.WriteEndObject();
                }
                return;
            default:
                {
                    WriteWarning?.Invoke($"Not supported Redis type: {type} of '{key}'.");
                }
                return;
        }
    }

    void WriteKey(Utf8JsonWriter writer, RedisKey key)
    {
        RedisType type = Database.KeyType(key);
        if (type == RedisType.None)
            return;

        var ttl = Database.KeyTimeToLive(key);
        if (ttl.HasValue && (!TimeToLive.HasValue || ttl.Value < TimeToLive.Value))
            return;

        WriteValue(writer, key, type, ttl);
    }

    protected override void Execute()
    {
        var options = new JsonWriterOptions
        {
            Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping,
            Indented = true,
        };

        using var writer = new Utf8JsonWriter(Stream, options);

        writer.WriteStartObject();

        foreach (RedisKey key in Keys)
            WriteKey(writer, key);

        writer.WriteEndObject();
    }
}
