using StackExchange.Redis;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisSet", DefaultParameterSetName = NMain)]
[OutputType(typeof(long))]
public sealed class GetSetCommand : BaseGetCountCmdlet
{
    const string NPattern = "Pattern";

    [Parameter(ParameterSetName = NPattern, Mandatory = true)]
    [AllowEmptyString]
    [AllowNull]
    public string Pattern { get; set; }

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
            case NPattern:
                {
                    if (Pattern is { })
                        Pattern = ConvertPatternToRedis(Pattern);

                    IEnumerable<RedisValue> res = Database.SetScan(RKey, RedisValue.Unbox(Pattern), 250, CommandFlags.None);
                    foreach (var value in res)
                        WriteObject((string)value);
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
