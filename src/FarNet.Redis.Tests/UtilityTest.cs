using FarNet.Redis.Commands;

namespace FarNet.Redis.Tests;

public class UtilityTest : AbcTest
{
    [Fact]
    public void WaitStringNull()
    {
        var key = "test:1";

        Database.KeyDelete(key);

        var command = new WaitString
        {
            Database = Database,
            Key = key,
            Delay = TimeSpan.FromMilliseconds(100),
            Timeout = TimeSpan.FromMilliseconds(500),
        };

        command.Invoke();
        Assert.Null(command.Result);

        Database.KeyDelete(key);
    }

    [Fact]
    public void WaitStringSome()
    {
        var key = "test:1";
        var value = NewGuid();

        Database.KeyDelete(key);

        var command = new WaitString
        {
            Database = Database,
            Key = key,
            Delay = TimeSpan.FromMilliseconds(100),
            Timeout = TimeSpan.FromMilliseconds(500),
        };

        Task.Run(() =>
        {
            Thread.Sleep(300);
            Database.StringSet(key, value);
        }, TestContext.Current.CancellationToken);

        command.Invoke();
        Assert.Equal(value, command.Result);

        Database.KeyDelete(key);
    }
}
