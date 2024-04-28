using StackExchange.Redis;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisList", DefaultParameterSetName = NMain)]
[OutputType(typeof(List<string>))]
[OutputType(typeof(string))]
[OutputType(typeof(long))]
public sealed class GetListCommand : BaseGetCountCmdlet
{
    const string NIndex = "Index";

    [Parameter(ParameterSetName = NIndex, Mandatory = true)]
    public long Index { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NCount:
                {
                    long res = Database.ListLength(RKey);
                    WriteObject(res);
                }
                break;
            case NIndex:
                {
                    RedisValue res = Database.ListGetByIndex(RKey, Index);
                    WriteObject((string)res);
                }
                break;
            default:
                {
                    RedisValue[] res = Database.ListRange(RKey);
                    if (res.Length > 0)
                        WriteObject(res.ToStringList());
                }
                break;
        }
    }
}
