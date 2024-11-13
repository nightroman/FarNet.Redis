using StackExchange.Redis;

namespace FarNet.Redis.Tests;

public class AnyTest
{
    protected IDatabase Database { get; }

    public AnyTest()
    {
        Database = DB.OpenDefaultDatabase();
    }

    protected static string NewGuid()
    {
        return Guid.NewGuid().ToString();
    }
}
