using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisKey")]
public sealed class SetKeyCommand : BaseKeyCmdlet
{
    const string NTimeToLive = "TimeToLive";

    [Parameter(Mandatory = true, ParameterSetName = NTimeToLive)]
    [AllowNull]
    public TimeSpan? TimeToLive { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NTimeToLive:
                {
                    Database.KeyExpire(RKey, TimeToLive);
                }
                break;
        }
    }
}
