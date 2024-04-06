using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisSet", DefaultParameterSetName = "Main")]
public sealed class SetSetCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    [ValidateNotNull]
    public string[] Value { get; set; }

    [Parameter(ParameterSetName = "Add", Mandatory = true)]
    public SwitchParameter Add { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var entries = new RedisValue[Value.Length];
        for (int i = 0; i < entries.Length; ++i)
            entries[i] = new RedisValue(Value[i]);

        if (!Add)
            Database.KeyDelete(RKey);

        Database.SetAdd(RKey, entries);
    }
}
