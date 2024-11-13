using FarNet.Redis.Commands;
using StackExchange.Redis;
using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Use", "RedisLock")]
[OutputType(typeof(PSObject))]
public sealed class UseLockCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public ScriptBlock Script { get; set; }

    [Parameter]
    public object Value { set => _Value = value.ToRedisValue(); }
    RedisValue _Value;

    [Parameter]
    public TimeSpan Delay { set { _delay = value; } }
    TimeSpan _delay = TimeSpan.FromSeconds(1);

    [Parameter]
    public TimeSpan Timeout { set { _timeout = value; } }
    TimeSpan _timeout = TimeSpan.FromMinutes(1);

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var command = new UseLock
        {
            Database = Database,
            Key = RKey,
            Value = _Value.IsNull ? Guid.NewGuid().ToByteArray() : _Value,
            Delay = _delay,
            Timeout = _timeout,
            Action = () =>
            {
                var res = Script.Invoke();
                foreach (var obj in res)
                    WriteObject(obj);
            }
        };

        Invoke(command);
    }
}
