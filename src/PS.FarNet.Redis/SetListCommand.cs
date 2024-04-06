using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisList", DefaultParameterSetName = "Main")]
public sealed class SetListCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    [AllowEmptyCollection]
    [AllowEmptyString]
    [ValidateNotNull]
    public string[] Value { get; set; }

    [Parameter(ParameterSetName = "LeftPush", Mandatory = true)]
    public SwitchParameter LeftPush { get; set; }

    [Parameter(ParameterSetName = "RightPush", Mandatory = true)]
    public SwitchParameter RightPush { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var entries = new RedisValue[Value.Length];
        for (int i = 0; i < entries.Length; ++i)
            entries[i] = new RedisValue(Value[i]);

        if (LeftPush)
        {
            Database.ListLeftPush(RKey, entries);
        }
        else if (RightPush)
        {
            Database.ListRightPush(RKey, entries);
        }
        else
        {
            Database.KeyDelete(RKey);
            Database.ListRightPush(RKey, entries);
        }
    }
}
