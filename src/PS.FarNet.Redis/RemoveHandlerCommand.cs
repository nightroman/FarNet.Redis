using StackExchange.Redis;
using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Remove", "RedisHandler")]
public sealed class RemoveHandlerCommand : BaseSubCmdlet
{
    [Parameter(Position = 1)]
    public PSObject Handler { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        Action<RedisChannel, RedisValue> action = null;
        if (Handler is { })
        {
            if (Handler.BaseObject is Action<RedisChannel, RedisValue> action2)
                action = action2;
            else
                throw new PSArgumentException($"The parameter Handler must be an object from Add-RedisHandler or null.");
        }

        Database.Multiplexer.GetSubscriber().Unsubscribe(Channel, action);
    }
}
