using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;

namespace PS.FarNet.Redis;

class ImportJson(string path, IDatabase database)
{
    static void AssertTokenType(JsonTokenType expected, JsonTokenType actual, object context)
    {
        if (expected != actual)
            throw new InvalidOperationException($"JSON: Expected token '{expected}', actual '{actual}', context: '{context}'.");
    }

    static RedisValue? TryReadRedisValue(ref Utf8JsonStreamReader reader, object context)
    {
        reader.Read();
        if (reader.TokenType == JsonTokenType.String)
            return reader.GetString();

        if (reader.TokenType != JsonTokenType.StartArray)
            return null;

        reader.Read();
        AssertTokenType(JsonTokenType.String, reader.TokenType, context);

        var bytes = reader.GetBytesFromBase64();

        reader.Read();
        AssertTokenType(JsonTokenType.EndArray, reader.TokenType, context);

        return bytes;
    }

    static RedisValue[] ReadRedisValueArray(ref Utf8JsonStreamReader reader, object context)
    {
        reader.Read();
        AssertTokenType(JsonTokenType.StartArray, reader.TokenType, context);

        var items = new List<RedisValue>();
        while (true)
        {
            var res = TryReadRedisValue(ref reader, context);
            if (!res.HasValue)
            {
                AssertTokenType(JsonTokenType.EndArray, reader.TokenType, context);
                break;
            }

            items.Add(res.Value);
        }
        return [.. items];
    }

    static HashEntry[] ReadHashEntryArray(ref Utf8JsonStreamReader reader, object context)
    {
        reader.Read();
        AssertTokenType(JsonTokenType.StartObject, reader.TokenType, context);

        var items = new List<HashEntry>();
        while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
        {
            AssertTokenType(JsonTokenType.PropertyName, reader.TokenType, context);

            var key = reader.GetString();
            var res = TryReadRedisValue(ref reader, context);
            if (!res.HasValue)
                throw new InvalidOperationException($"JSON: Expected token 'String' or 'StartArray', actual '{reader.TokenType}', context: '{context}/{key}'.");

            items.Add(new HashEntry(key, res.Value));
        }
        return [.. items];
    }

    public void Invoke()
    {
        using var stream = File.OpenRead(path);
        var reader = new Utf8JsonStreamReader(stream, 32 * 1024);
        try
        {
            reader.Read();
            AssertTokenType(JsonTokenType.StartObject, reader.TokenType, "ROOT");

            while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
            {
                AssertTokenType(JsonTokenType.PropertyName, reader.TokenType, "KEY");
                var key = reader.GetString();

                var res = TryReadRedisValue(ref reader, key);
                if (res.HasValue)
                {
                    database.StringSet(key, res.Value);
                    continue;
                }

                AssertTokenType(JsonTokenType.StartObject, reader.TokenType, key);

                DateTime? eol = null;
                Action save = null;
                while (reader.Read() && reader.TokenType != JsonTokenType.EndObject)
                {
                    AssertTokenType(JsonTokenType.PropertyName, reader.TokenType, key);

                    var name = reader.GetString();
                    switch (name)
                    {
                        case "Text":
                            {
                                reader.Read();
                                AssertTokenType(JsonTokenType.String, reader.TokenType, key);

                                string value = reader.GetString();
                                save = () => database.StringSet(key, value);
                            }
                            break;
                        case "Blob":
                            {
                                reader.Read();
                                AssertTokenType(JsonTokenType.String, reader.TokenType, key);

                                byte[] value = reader.GetBytesFromBase64();
                                save = () => database.StringSet(key, value);
                            }
                            break;
                        case "Hash":
                            {
                                var items = ReadHashEntryArray(ref reader, key);
                                database.KeyDelete(key);
                                save = () => database.HashSet(key, items);
                            }
                            break;
                        case "List":
                            {
                                var items = ReadRedisValueArray(ref reader, key);
                                database.KeyDelete(key);
                                save = () => database.ListRightPush(key, items);
                            }
                            break;
                        case "Set":
                            {
                                var items = ReadRedisValueArray(ref reader, key);
                                database.KeyDelete(key);
                                save = () => database.SetAdd(key, items);
                            }
                            break;
                        case "EOL":
                            {
                                reader.Read();
                                AssertTokenType(JsonTokenType.String, reader.TokenType, key);

                                eol = DateTime.Parse(reader.GetString());
                            }
                            break;
                        default:
                            {
                                throw new InvalidOperationException($"JSON: Unexpected property '{name}'.");
                            }
                    }
                }

                if (!eol.HasValue || eol > DateTime.UtcNow)
                {
                    save();
                    if (eol.HasValue)
                        database.KeyExpire(key, eol - DateTime.Now);
                }
            }
        }
        finally
        {
            reader.Dispose();
        }
    }
}
