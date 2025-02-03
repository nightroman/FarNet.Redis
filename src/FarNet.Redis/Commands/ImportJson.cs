using FarNet.Redis.Tools;
using StackExchange.Redis;
using System.Globalization;
using System.Text;
using System.Text.Json;

namespace FarNet.Redis.Commands;

public sealed class ImportJson : BaseDBCommand
{
    // required
    public required Stream Stream { get; init; }

    string _key = "";
    string _name = "";
    string _field = "";

    void AssertTokenType(JsonTokenType expected, JsonTokenType actual)
    {
        if (expected != actual)
            throw new InvalidOperationException($"Unexpected token '{actual}'.");
    }

    RedisValue? TryReadStringOrBytes(ref Utf8JsonStreamReader reader)
    {
        reader.Read();
        switch (reader.TokenType)
        {
            case JsonTokenType.String:
                {
                    return reader.GetString();
                }
            case JsonTokenType.StartArray:
                {
                    reader.Read();
                    AssertTokenType(JsonTokenType.String, reader.TokenType);

                    var bytes = reader.GetBytesFromBase64();

                    reader.Read();
                    AssertTokenType(JsonTokenType.EndArray, reader.TokenType);

                    return bytes;
                }
        }
        return null;
    }

    (RedisValue, DateTime?) ReadStringOrBytesWithEol(ref Utf8JsonStreamReader reader)
    {
        var res = TryReadStringOrBytes(ref reader);
        if (res.HasValue)
            return (res.Value, null);

        AssertTokenType(JsonTokenType.StartObject, reader.TokenType);

        RedisValue? value = null;
        DateTime? eol = null;
        while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
        {
            var name = reader.GetString();
            switch (name)
            {
                case ExportJson.KeyEol:
                    {
                        reader.Read();
                        AssertTokenType(JsonTokenType.String, reader.TokenType);

                        eol = DateTime.Parse(reader.GetString(), null, DateTimeStyles.AssumeUniversal);
                    }
                    break;
                case ExportJson.KeyText:
                    {
                        reader.Read();
                        AssertTokenType(JsonTokenType.String, reader.TokenType);

                        value = reader.GetString();
                    }
                    break;
                case ExportJson.KeyBlob:
                    {
                        reader.Read();
                        AssertTokenType(JsonTokenType.String, reader.TokenType);

                        value = reader.GetBytesFromBase64();
                    }
                    break;
                default:
                    {
                        throw new InvalidOperationException($"Unexpected property '{name}'.");
                    }
            }
        }

        if (value.HasValue)
            return (value.Value, eol);

        throw new InvalidOperationException("Missing expected value.");
    }

    RedisValue[] ReadRedisValueArray(ref Utf8JsonStreamReader reader)
    {
        reader.Read();
        AssertTokenType(JsonTokenType.StartArray, reader.TokenType);

        var items = new List<RedisValue>();
        while (true)
        {
            var res = TryReadStringOrBytes(ref reader);
            if (!res.HasValue)
            {
                AssertTokenType(JsonTokenType.EndArray, reader.TokenType);
                break;
            }

            items.Add(res.Value);
        }
        return [.. items];
    }

    List<(HashEntry entry, DateTime? eol)> ReadHashEntriesWithEol(ref Utf8JsonStreamReader reader)
    {
        reader.Read();
        AssertTokenType(JsonTokenType.StartObject, reader.TokenType);

        var items = new List<(HashEntry entry, DateTime? eol)>();
        while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
        {
            _field = reader.GetString();
            var (value, eol) = ReadStringOrBytesWithEol(ref reader);

            if (!eol.HasValue || eol.Value > DateTime.UtcNow)
                items.Add((new HashEntry(_field, value), eol));
        }

        _field = "";
        return items;
    }

    // Ensures at least a millisecond, to avoid errors.
    static TimeSpan PositiveTimeToLive(DateTime eol)
    {
        var ttl = eol - DateTime.UtcNow;
        return ttl.TotalMilliseconds >= 1 ? ttl : TimeSpan.FromMilliseconds(1);
    }

    protected override void Execute()
    {
        // skip BOM
        if (Stream.ReadByte() != 0xEF || Stream.ReadByte() != 0xBB || Stream.ReadByte() != 0xBF)
            Stream.Position = 0;

        var reader = new Utf8JsonStreamReader(Stream, 32 * 1024);
        try
        {
            reader.Read();
            AssertTokenType(JsonTokenType.StartObject, reader.TokenType);

            while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
            {
                _key = reader.GetString();
                _name = "";

                var res = TryReadStringOrBytes(ref reader);
                if (res.HasValue)
                {
                    Database.StringSet(_key, res.Value);
                    continue;
                }

                AssertTokenType(JsonTokenType.StartObject, reader.TokenType);

                // read {"key": {...
                DateTime? eol = null;
                Action? save = null;
                while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
                {
                    _name = reader.GetString();
                    switch (_name)
                    {
                        case ExportJson.KeyEol:
                            {
                                reader.Read();
                                AssertTokenType(JsonTokenType.String, reader.TokenType);

                                eol = DateTime.Parse(reader.GetString(), null, DateTimeStyles.AssumeUniversal);
                            }
                            break;
                        case ExportJson.KeyText:
                            {
                                reader.Read();
                                AssertTokenType(JsonTokenType.String, reader.TokenType);

                                string value = reader.GetString();
                                save = () => Database.StringSet(_key, value);
                            }
                            break;
                        case ExportJson.KeyBlob:
                            {
                                reader.Read();
                                AssertTokenType(JsonTokenType.String, reader.TokenType);

                                byte[] value = reader.GetBytesFromBase64();
                                save = () => Database.StringSet(_key, value);
                            }
                            break;
                        case ExportJson.KeyList:
                            {
                                var items = ReadRedisValueArray(ref reader);
                                Database.KeyDelete(_key);
                                save = () => Database.ListRightPush(_key, items);
                            }
                            break;
                        case ExportJson.KeySet:
                            {
                                var items = ReadRedisValueArray(ref reader);
                                Database.KeyDelete(_key);
                                save = () => Database.SetAdd(_key, items);
                            }
                            break;
                        case ExportJson.KeyHash:
                            {
                                var items = ReadHashEntriesWithEol(ref reader);
                                Database.KeyDelete(_key);

                                var entries = items.Select(x => x.entry).ToArray();
                                if (entries.Length > 0)
                                {
                                    save = () =>
                                    {
                                        Database.HashSet(_key, entries);

                                        foreach (var item in items)
                                        {
                                            if (item.eol.HasValue)
                                                Database.HashFieldExpire(_key, [item.entry.Name], PositiveTimeToLive(item.eol.Value));
                                        }
                                    };
                                }
                            }
                            break;
                        default:
                            {
                                throw new InvalidOperationException($"Unexpected property '{_name}'.");
                            }
                    }
                }

                if (save is null)
                    continue;

                if (!eol.HasValue || eol > DateTime.UtcNow)
                {
                    save();
                    if (eol.HasValue)
                        Database.KeyExpire(_key, PositiveTimeToLive(eol.Value));
                }
            }
        }
        catch (Exception ex)
        {
            var sb = new StringBuilder("JSON: ");
            if (_key.Length > 0)
            {
                sb.Append(_key);
                if (_name.Length > 0)
                {
                    sb.Append('/').Append(_name);
                    if (_field.Length > 0)
                        sb.Append('/').Append(_field);
                }
                sb.Append(": ");
            }
            sb.Append(ex.Message);

            throw new InvalidOperationException(sb.ToString(), ex);
        }
        finally
        {
            reader.Dispose();
        }
    }
}
