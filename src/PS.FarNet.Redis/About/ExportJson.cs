using StackExchange.Redis;
using System;
using System.IO;
using System.Text.Json;

namespace PS.FarNet.Redis;

class ExportJson(string Path, IDatabase Database)
{
    public string Pattern { get; set; }
    public TimeSpan? TimeToLive { get; set; }
    public Action<string> WriteWarning { get; set; }

    static void WriteBlobOrText(Utf8JsonWriter writer, RedisValue value)
    {
        var text = (string)value;
        if (text.IsAscii())
        {
            writer.WriteString("Text", text);
        }
        else
        {
            writer.WriteBase64String("Blob", (byte[])value);
        }
    }

    static void WriteString(Utf8JsonWriter writer, RedisValue value, bool isList=false)
    {
        var text = (string)value;
        if (text.IsAscii())
        {
            writer.WriteStringValue(text);
        }
        else
        {
            var base64 = Convert.ToBase64String(value);
            var json = isList ? $"{Environment.NewLine}      [\"{base64}\"]" : $"[\"{base64}\"]";
            writer.WriteRawValue(json, true);
        }
    }

    static void WriteEndOfLife(Utf8JsonWriter writer, TimeSpan? ttl)
    {
        if (ttl.HasValue)
            writer.WriteString("EOL", (DateTime.UtcNow + ttl.Value).ToString("yyyy-MM-dd HH:mm"));
    }

    void WriteValue(Utf8JsonWriter writer, RedisKey key, RedisType type, TimeSpan? ttl)
    {
        switch (type)
        {
            case RedisType.String:
                {
                    RedisValue res = Database.StringGet(key);
                    if (!res.HasValue)
                        return;

                    writer.WritePropertyName(key);
                    if (ttl.HasValue)
                    {
                        writer.WriteStartObject();
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

                    writer.WritePropertyName(key);
                    writer.WriteStartObject();
                    WriteEndOfLife(writer, ttl);

                    writer.WritePropertyName("Hash");
                    writer.WriteStartObject();
                    foreach (HashEntry entry in res)
                    {
                        writer.WritePropertyName(entry.Name);
                        WriteString(writer, entry.Value);
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

                    writer.WritePropertyName(key);
                    writer.WriteStartObject();
                    WriteEndOfLife(writer, ttl);

                    writer.WritePropertyName("List");
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

                    writer.WritePropertyName(key);
                    writer.WriteStartObject();
                    WriteEndOfLife(writer, ttl);

                    writer.WritePropertyName("Set");
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

    public void Invoke()
    {
        var server = Database.Multiplexer.GetServers()[0];
        var keys = server.Keys(Database.Database, Pattern);

        var options = new JsonWriterOptions { Indented = true, };
        using var stream = new FileStream(Path, FileMode.Create);
        using var writer = new Utf8JsonWriter(stream, options);

        writer.WriteStartObject();
        foreach (RedisKey key in keys)
            WriteKey(writer, key);


        writer.WriteEndObject();
    }
}
