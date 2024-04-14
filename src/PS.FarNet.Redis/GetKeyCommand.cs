using StackExchange.Redis;
using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisKey", DefaultParameterSetName = NMain)]
[OutputType(typeof(RedisType))]
[OutputType(typeof(TimeSpan))]
public sealed class GetKeyCommand : BaseKeyCmdlet
{
    [Parameter(ParameterSetName = "TimeToLive", Mandatory = true)]
    public SwitchParameter TimeToLive { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (TimeToLive)
        {
            var res = Database.KeyTimeToLive(RKey);
            WriteObject(res);
        }
        else
        {
            var res = Database.KeyType(RKey);
            WriteObject(res);
        }
    }
}
