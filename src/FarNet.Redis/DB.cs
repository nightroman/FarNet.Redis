using System;
using System.Collections.Concurrent;
using System.Linq;

namespace StackExchange.Redis;

public static class DB
{
    private static readonly ConcurrentDictionary<string, IDatabase> s_databases = [];
    private static IDatabase? s_database;

    public static IDatabase? DefaultDatabase => s_database;

    public static IDatabase OpenDefaultDatabase()
    {
        if (s_database is { })
            return s_database;

        var configuration = Environment.GetEnvironmentVariable("FARNET_REDIS_CONFIGURATION")
            ?? throw new InvalidOperationException("Requires environment variable FARNET_REDIS_CONFIGURATION.");

        return s_database = Open(configuration);
    }

    public static IDatabase Open(string configuration)
    {
        var options = ConfigurationOptions.Parse(configuration);
        return Open(options);
    }

    public static IDatabase Open(ConfigurationOptions options)
    {
        var key = options.ToString();
        var db = s_databases.GetOrAdd(key, key =>
        {
            var redis = ConnectionMultiplexer.Connect(options);
            return redis.GetDatabase();
        });

        return db;
    }

    public static void Close(string configuration)
    {
        var options = ConfigurationOptions.Parse(configuration);

        var key = options.ToString();
        if (s_databases.TryRemove(key, out IDatabase? db))
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
}
