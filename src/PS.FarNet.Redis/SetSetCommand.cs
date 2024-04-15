using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisSet", DefaultParameterSetName = NMain)]
public sealed class SetSetCommand : BaseKeyCmdlet
{
    const string NAdd = "Add";
    const string NRemove = "Remove";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    [AllowEmptyString]
    public object[] Value { set => _Value = Abc.ToRedis(value); }
    RedisValue[] _Value;

    [Parameter(Mandatory = true, ParameterSetName = NAdd)]
    [AllowEmptyString]
    public object[] Add { set => _Add = Abc.ToRedis(value); }
    RedisValue[] _Add;

    [Parameter(Mandatory = true, ParameterSetName = NRemove)]
    [AllowEmptyString]
    public object[] Remove { set => _Remove = Abc.ToRedis(value); }
    RedisValue[] _Remove;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NAdd:
                {
                    Database.SetAdd(RKey, _Add);
                }
                break;
            case NRemove:
                {
                    Database.SetRemove(RKey, _Remove);
                }
                break;
            default:
                {
                    Database.KeyDelete(RKey);
                    Database.SetAdd(RKey, _Value);
                }
                break;
        }
    }
}
