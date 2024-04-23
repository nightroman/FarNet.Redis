using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Test", "RedisKey")]
[OutputType(typeof(long))]
public sealed class TestKeyCommand : BaseKeysCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Key.Length == 1)
        {
            bool res = Database.KeyExists(Key[0]);
            WriteObject(res ? 1L : 0L);
        }
        else
        {
            long res = Database.KeyExists(Key.ToRedisKeyArray());
            WriteObject(res);
        }
    }
}
