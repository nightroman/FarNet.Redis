using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisSet", DefaultParameterSetName = NMain)]
public sealed class SetSetCommand : BaseKeyCmdlet
{
    const string NRemove = "Remove";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    [AllowEmptyString]
    public object[] Add { set => _Add = value.ToRedisValueArray(); }
    RedisValue[] _Add;

    [Parameter(Mandatory = true, ParameterSetName = NRemove)]
    [AllowEmptyString]
    public object[] Remove { set => _Remove = value.ToRedisValueArray(); }
    RedisValue[] _Remove;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NRemove:
                {
                    Database.SetRemove(RKey, _Remove);
                }
                return;
        }

        if (_Add.Length == 1)
        {
            Database.SetAdd(RKey, _Add[0]);
        }
        else
        {
            Database.SetAdd(RKey, _Add);
        }
    }
}
