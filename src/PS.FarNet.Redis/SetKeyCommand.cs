using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisKey")]
public sealed class SetKeyCommand : BaseKeyCmdlet
{
    [Parameter]
    public TimeSpan? TimeToLive { set { _isTimeToLive = true; _TimeToLive = value; } }
    TimeSpan? _TimeToLive;
    bool _isTimeToLive;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (_isTimeToLive)
        {
            Database.KeyExpire(RKey, _TimeToLive);
        }
    }
}
