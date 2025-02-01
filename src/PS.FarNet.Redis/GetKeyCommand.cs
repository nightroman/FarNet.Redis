using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisKey", DefaultParameterSetName = NMain)]
[OutputType(typeof(RedisType))]
[OutputType(typeof(TimeSpan))]
public sealed class GetKeyCommand : BaseKeyCmdlet
{
    const string NTimeToLive = "TimeToLive";

    [Parameter(ParameterSetName = NTimeToLive, Mandatory = true)]
    public SwitchParameter TimeToLive { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NTimeToLive:
                {
                    TimeSpan? res = Database.KeyTimeToLive(RKey);
                    WriteObject(res);
                }
                break;
            default:
                {
                    RedisType res = Database.KeyType(RKey);
                    WriteObject(res);
                }
                break;
        }
    }
}
