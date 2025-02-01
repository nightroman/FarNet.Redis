using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Add", "RedisHandler")]
[OutputType(typeof(object))]
public sealed class AddHandlerCommand : BaseSubCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public ScriptBlock Handler { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var action = CreateHandler(Handler);

        Database.Multiplexer.GetSubscriber().Subscribe(Channel, action);

        WriteObject(action);
    }

    static Action<RedisChannel, RedisValue> CreateHandler(ScriptBlock handler)
    {
        return (channel, value) => handler.Invoke(channel, (string)value);
    }
}
