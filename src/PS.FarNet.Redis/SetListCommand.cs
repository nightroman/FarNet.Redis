using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisList", DefaultParameterSetName = NMain)]
[OutputType(typeof(string))]
public sealed class SetListCommand : BaseKeyCmdlet
{
    const string NLeftPush = "LeftPush";
    const string NRightPush = "RightPush";
    const string NLeftPop = "LeftPop";
    const string NRightPop = "RightPop";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    [AllowEmptyString]
    public string[] Value { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NLeftPush)]
    [AllowEmptyString]
    public string[] LeftPush { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NRightPush)]
    [AllowEmptyString]
    public string[] RightPush { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NLeftPop)]
    [ValidateRange(1L, long.MaxValue)]
    public long LeftPop { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NRightPop)]
    [ValidateRange(1L, long.MaxValue)]
    public long RightPop { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NLeftPush:
                {
                    Database.ListLeftPush(RKey, Abc.ToRedis(LeftPush));
                }
                break;
            case NRightPush:
                {
                    Database.ListRightPush(RKey, Abc.ToRedis(RightPush));
                }
                break;
            case NLeftPop:
                {
                    var res = Database.ListLeftPop(RKey, LeftPop);
                    WriteObject(Abc.ToList(res), true);
                }
                break;
            case NRightPop:
                {
                    var res = Database.ListRightPop(RKey, RightPop);
                    WriteObject(Abc.ToList(res), true);
                }
                break;
            default:
                {
                    Database.KeyDelete(RKey);
                    Database.ListRightPush(RKey, Abc.ToRedis(Value));
                }
                break;
        }
    }
}
