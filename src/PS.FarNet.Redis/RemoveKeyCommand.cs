using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Remove", "RedisKey")]
[OutputType(typeof(long))]
public sealed class RemoveKeyCommand : BaseKeysCmdlet
{
    [Parameter]
    public SwitchParameter Result { get; set; }

    protected override void BeginProcessing()
    {
        if (Key is null || Key.Length == 0)
        {
            if (Result)
                WriteObject(0L);

            return;
        }

        base.BeginProcessing();

        if (Key.Length == 1)
        {
            bool res = Database.KeyDelete(Key[0]);
            if (Result)
                WriteObject(res ? 1L : 0L);
        }
        else
        {
            long res = Database.KeyDelete(Key.ToRedisKeyArray());
            if (Result)
                WriteObject(res);
        }
    }
}
