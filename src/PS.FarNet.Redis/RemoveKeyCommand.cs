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
        base.BeginProcessing();

        if (Key.Length == 1)
        {
            var res = Database.KeyDelete(Key[0]);
            if (Result)
                WriteObject(res ? 1L : 0L);
        }
        else
        {
            var res = Database.KeyDelete(Abc.ToKeys(Key));
            if (Result)
                WriteObject(res);
        }
    }
}
