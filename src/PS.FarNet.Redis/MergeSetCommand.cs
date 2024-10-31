using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Merge", "RedisSet", DefaultParameterSetName = NMain)]
[OutputType(typeof(string))]
[OutputType(typeof(long))]
public sealed class MergeSetCommand : BaseDBCmdlet
{
    const string NDestination = "Destination";

    [Parameter(Position = 0, Mandatory = true)]
    public SetOperation Operation { get; set; }

    [Parameter(Position = 1, Mandatory = true)]
    public string[] Source { get; set; }

    [Parameter(ParameterSetName = NDestination, Mandatory = true)]
    public string Destination { get; set; }

    [Parameter(ParameterSetName = NDestination)]
    public SwitchParameter Result { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NDestination:
                {
                    long res = Database.SetCombineAndStore(Operation, new RedisKey(Destination), Source.ToRedisKeyArray());
                    if (Result)
                        WriteObject(res);
                }
                break;
            default:
                {
                    RedisValue[] res = Database.SetCombine(Operation, Source.ToRedisKeyArray());
                    foreach (var item in res)
                        WriteObject((string)item);
                }
                break;
        }
    }
}
