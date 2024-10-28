using StackExchange.Redis;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace PS.FarNet.Redis;

static class ExtensionMethods
{
    public static bool IsAscii(this string value)
    {
        return value.All(x => x < 128);
    }

    public static object ToBaseObject(this object value)
    {
        return value is PSObject ps ? ps.BaseObject : value;
    }

    public static RedisValue ToRedisValue(this object value)
    {
        try
        {
            return RedisValue.Unbox(value is PSObject ps ? ps.BaseObject : value);
        }
        catch (Exception ex)
        {
            throw new ArgumentException($"Cannot bind '{value.ToBaseObject().GetType().Name}' to 'RedisValue': {ex.Message}", ex);
        }
    }

    public static Hashtable ToHashtable(this HashEntry[] hash)
    {
        var result = new Hashtable(hash.Length, StringComparer.Ordinal);
        for (int i = 0; i < hash.Length; i++)
            result.Add((string)hash[i].Name, (string)hash[i].Value);
        return result;
    }

    public static Hashtable ToHashtable(this IEnumerable<HashEntry> hash)
    {
        var result = new Hashtable(StringComparer.Ordinal);
        foreach (var entry in hash)
            result.Add((string)entry.Name, (string)entry.Value);
        return result;
    }

    public static HashSet<string> ToStringHashSet(this RedisValue[] values)
    {
        var result = new HashSet<string>();
        foreach (var value in values)
            result.Add((string)value);
        return result;
    }

    public static RedisKey[] ToRedisKeyArray(this string[] keys)
    {
        return Array.ConvertAll(keys, x => new RedisKey(x));
    }

    public static List<string> ToStringList(this RedisValue[] values)
    {
        var result = new List<string>(values.Length);
        foreach (var value in values)
            result.Add((string)value);
        return result;
    }

    public static RedisValue[] ToRedisValueArray(this object[] input)
    {
        return Array.ConvertAll(input, ToRedisValue);
    }

    public static HashEntry[] ToHashEntryArray(this IDictionary input)
    {
        var entries = new HashEntry[input.Count];
        var i = -1;
        foreach (DictionaryEntry kv in input)
        {
            ++i;
            entries[i] = new(kv.Key.ToRedisValue(), kv.Value.ToRedisValue());
        }

        return entries;
    }

    public static KeyValuePair<RedisKey, RedisValue>[] ToRedisKeyValuePairArray(this IDictionary input)
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
