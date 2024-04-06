
using System.Collections.Concurrent;
using System.Linq;

namespace StackExchange.Redis;

public static class DB
{
    static readonly ConcurrentDictionary<string, IDatabase> _db = [];

    public static IDatabase Open(string configuration)
    {
        ConfigurationOptions options = ConfigurationOptions.Parse(configuration);

        var key = options.ToString();
        var db = _db.GetOrAdd(key, key =>
        {
            var redis = ConnectionMultiplexer.Connect(options);
            return redis.GetDatabase();
        });

        return db;
    }

    public static void Close(string configuration)
    {
        ConfigurationOptions options = ConfigurationOptions.Parse(configuration);

        var key = options.ToString();
        if (_db.TryRemove(key, out IDatabase? db))
            db.Multiplexer.Close();
    }

    public static void Close(IDatabase db)
    {
        db.Multiplexer.Close();
        foreach (var kv in _db.ToList())
        {
            if (ReferenceEquals(kv.Value, db))
                _db.TryRemove(kv.Key, out _);
        }
    }
}
