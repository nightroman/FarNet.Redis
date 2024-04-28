using StackExchange.Redis;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisSet", DefaultParameterSetName = NMain)]
[OutputType(typeof(HashSet<string>))]
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
                    if (res.Length > 0)
                        WriteObject(res.ToStringHashSet());
                }
                break;
        }
    }
}
