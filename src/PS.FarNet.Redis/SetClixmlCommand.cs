using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisClixml")]
public sealed class SetClixmlCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public object Value { get; set; }

    [Parameter]
    public int Depth { get; set; } = 1;

    [Parameter]
    public TimeSpan? TimeToLive { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var str = PSSerializer.Serialize(Value, Depth);
        Database.StringSet(RKey, str, TimeToLive, When.Always);
    }
}
