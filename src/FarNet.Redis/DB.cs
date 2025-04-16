using FarNet.Redis;
using System.Collections.Concurrent;

#pragma warning disable IDE0130
namespace StackExchange.Redis;

public static class DB
{
    const int DefaultIndex = -1;

    private static readonly ConcurrentDictionary<(string, int), IDatabase> s_databases = [];
    private static IDatabase? s_database;

    public static IDatabase? DefaultDatabase => s_database;

    public static IDatabase OpenDefaultDatabase(Action<ConfigurationOptions>? configure = null)
    {
        if (s_database is { })
            return s_database;

        var configuration = Environment.GetEnvironmentVariable("FARNET_REDIS_CONFIGURATION")
            ?? throw new InvalidOperationException("Requires environment variable FARNET_REDIS_CONFIGURATION.");

        var options = ConfigurationOptions.Parse(configuration);
        configure?.Invoke(options);

        return s_database = Open(options);
    }

    public static IDatabase Open(string configuration, int index = DefaultIndex)
    {
        var options = ConfigurationOptions.Parse(configuration);
        return Open(options, index);
    }

    public static IDatabase Open(ConfigurationOptions options, int index = DefaultIndex)
    {
        var key = options.ToString();
        var db = s_databases.GetOrAdd((key, index), key =>
        {
            var redis = ConnectionMultiplexer.Connect(options);
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
        if (ReferenceEquals(s_database, db))
            s_database = null;

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
