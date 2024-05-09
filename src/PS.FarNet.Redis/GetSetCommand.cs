using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisSet", DefaultParameterSetName = NMain)]
[OutputType(typeof(long))]
public sealed class GetSetCommand : BaseGetCountCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NCount:
                {
                    long res = Database.SetLength(RKey);
                    WriteObject(res);
                }
                break;
            default:
                {
                    RedisValue[] res = Database.SetMembers(RKey);
                    foreach (var value in res)
                        WriteObject((string)value);
                }
                break;
        }
    }
}
