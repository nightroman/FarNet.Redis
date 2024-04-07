using StackExchange.Redis;
using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Register", "RedisSub")]
[OutputType(typeof(object))]
public sealed class RegisterSubCommand : BaseSubCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public ScriptBlock Script { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var sub = Database.Multiplexer.GetSubscriber();
        var action = new Action<RedisChannel, RedisValue>(Handler);
        sub.Subscribe(Channel, action);
        WriteObject(action);
    }

    void Handler(RedisChannel channel, RedisValue value)
    {
        Script.Invoke(channel, (string)value);
    }
}
