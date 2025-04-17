using StackExchange.Redis;

namespace FarNet.Redis.Tests;

public class AbcTest
{
    protected IDatabase Database { get; }

    public AbcTest()
    {
        Database = DB.Open(DB.DefaultConfiguration);
    }

    protected static string NewGuid()
    {
        return Guid.NewGuid().ToString();
    }
}
