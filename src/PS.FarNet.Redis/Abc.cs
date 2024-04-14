using StackExchange.Redis;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

static class Abc
{
    public static object BaseObject(object value)
    {
        return value is PSObject ps ? ps.BaseObject : value;
    }

    public static Dictionary<string, string> ToDictionary(HashEntry[] entries)
    {
        var result = new Dictionary<string, string>(entries.Length);
        foreach (var entry in entries)
            result.Add((string)entry.Name, (string)entry.Value);
        return result;
    }

    public static HashSet<string> ToHashSet(RedisValue[] values)
    {
        var result = new HashSet<string>();
        foreach (var value in values)
            result.Add((string)value);
        return result;
    }

    public static RedisKey[] ToKeys(string[] keys)
    {
        var result = new RedisKey[keys.Length];
        for (var i = 0; i < keys.Length; ++i)
            result[i] = keys[i];
        return result;
    }

    public static List<string> ToList(RedisValue[] values)
    {
        var result = new List<string>(values.Length);
        foreach (var value in values)
            result.Add((string)value);
        return result;
    }

    public static RedisValue[] ToRedis(string[] input)
    {
        var entries = new RedisValue[input.Length];
        for (int i = 0; i < entries.Length; ++i)
            entries[i] = new RedisValue(input[i]);

        return entries;
    }

    public static HashEntry[] ToRedis(IDictionary input)
    {
        var entries = new HashEntry[input.Count];
        var i = -1;
        foreach (DictionaryEntry kv in input)
        {
            ++i;
            entries[i] = new(new RedisValue(kv.Key?.ToString()), new RedisValue(kv.Value?.ToString()));
        }

        return entries;
    }

    public static KeyValuePair<RedisKey, RedisValue>[] ToRedisPairs(IDictionary input)
    {
        var entries = new KeyValuePair<RedisKey, RedisValue>[input.Count];
        var i = -1;
        foreach (DictionaryEntry kv in input)
        {
            ++i;
            entries[i] = new(new RedisKey(kv.Key?.ToString()), new RedisValue(kv.Value?.ToString()));
        }

        return entries;
    }
}
