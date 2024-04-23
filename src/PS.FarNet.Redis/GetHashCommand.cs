using StackExchange.Redis;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisHash", DefaultParameterSetName = NMain)]
[OutputType(typeof(Dictionary<string, string>))]
[OutputType(typeof(string))]
[OutputType(typeof(long))]
public sealed class GetHashCommand : BaseGetCountCmdlet
{
    const string NField = "Field";

    [Parameter(Mandatory = true, ParameterSetName = NField)]
    public string[] Field { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NCount:
                {
                    long res = Database.HashLength(RKey);
                    WriteObject(res);
                }
                break;
            case NField when Field.Length == 1:
                {
                    RedisValue res = Database.HashGet(RKey, Field[0]);
                    WriteObject((string)res);
                }
                break;
            case NField:
                {
                    RedisValue[] res = Database.HashGet(RKey, Field.ToRedisValueArray());
                    foreach (var item in res)
                        WriteObject((string)item);
                }
                break;
            default:
                {
                    HashEntry[] res = Database.HashGetAll(RKey);
                    WriteObject(res.ToStringDictionary());
                }
                break;
        }
    }
}
