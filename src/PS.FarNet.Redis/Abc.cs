using StackExchange.Redis;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

static class Abc
{
    public static string[] OneNullString = [null];

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
}
