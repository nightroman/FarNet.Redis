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
    public object[] Value { set => _Value = Abc.ToRedis(value); }
    RedisValue[] _Value;

    [Parameter(Mandatory = true, ParameterSetName = NLeftPush)]
    [AllowEmptyString]
    public object[] LeftPush { set => _LeftPush = Abc.ToRedis(value); }
    RedisValue[] _LeftPush;

    [Parameter(Mandatory = true, ParameterSetName = NRightPush)]
    [AllowEmptyString]
    public object[] RightPush { set => _RightPush = Abc.ToRedis(value); }
    RedisValue[] _RightPush;

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
                    Database.ListLeftPush(RKey, _LeftPush);
                }
                break;
            case NRightPush:
                {
                    Database.ListRightPush(RKey, _RightPush);
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
                    Database.ListRightPush(RKey, _Value);
                }
                break;
        }
    }
}
