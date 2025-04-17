using FarNet.Redis;
using System.Collections.Concurrent;

#pragma warning disable IDE0130
namespace StackExchange.Redis;

public static class DB
{
    const int DefaultIndex = -1;

    private static readonly ConcurrentDictionary<(string, int), IDatabase> s_databases = [];

    public static string DefaultConfiguration =>
        Environment.GetEnvironmentVariable("FARNET_REDIS_CONFIGURATION")
        ?? throw new InvalidOperationException("Requires environment variable FARNET_REDIS_CONFIGURATION.");

    public static IDatabase Open(string configuration, int index = DefaultIndex)
    {
        var db = s_databases.GetOrAdd((configuration, index), key =>
        {
            var redis = ConnectionMultiplexer.Connect(key.Item1);
            return redis.GetDatabase(key.Item2);
        });
        return db;
    }

    public static void Close(string configuration, int index = DefaultIndex)
    {
        var options = ConfigurationOptions.Parse(configuration);

        var key = options.ToString();
        if (s_databases.TryRemove((key, index), out IDatabase? db))
            db.Multiplexer.Close();
    }

    public static void Close(IDatabase db)
    {
        db.Multiplexer.Close();
        foreach (var kv in s_databases.ToList())
        {
            if (ReferenceEquals(kv.Value, db))
                s_databases.TryRemove(kv.Key, out _);
        }
    }

    public static IEnumerable<RedisKey> Keys(IDatabase db, RedisValue pattern)
    {
        var server = AboutRedis.GetServer(db.Multiplexer);
        return server.Keys(db.Database, pattern);
    }
}
