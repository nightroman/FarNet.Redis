using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisList", DefaultParameterSetName = NMain)]
[OutputType(typeof(string))]
public sealed class SetListCommand : BaseKeyCmdlet
{
    const string NLeftPush = "LeftPush";
    const string NLeftPop = "LeftPop";
    const string NRightPop = "RightPop";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    [AllowEmptyString]
    public object[] RightPush { set => _RightPush = value.ToRedisValueArray(); }
    RedisValue[] _RightPush;

    [Parameter(Mandatory = true, ParameterSetName = NLeftPush)]
    [AllowEmptyString]
    public object[] LeftPush { set => _LeftPush = value.ToRedisValueArray(); }
    RedisValue[] _LeftPush;

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
            case NMain:
                {
                    Database.ListRightPush(RKey, _RightPush);
                }
                break;
            case NLeftPush:
                {
                    Database.ListLeftPush(RKey, _LeftPush);
                }
                break;
            case NLeftPop:
                {
                    var res = Database.ListLeftPop(RKey, LeftPop);
                    WriteObject(res.ToStringList(), true);
                }
                break;
            case NRightPop:
                {
                    var res = Database.ListRightPop(RKey, RightPop);
                    WriteObject(res.ToStringList(), true);
                }
                break;
        }
    }
}
