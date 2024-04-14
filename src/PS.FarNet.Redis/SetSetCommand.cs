using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisSet", DefaultParameterSetName = NMain)]
public sealed class SetSetCommand : BaseKeyCmdlet
{
    const string NAdd = "Add";
    const string NRemove = "Remove";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    [AllowEmptyString]
    public string[] Value { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NAdd)]
    [AllowEmptyString]
    public string[] Add { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NRemove)]
    [AllowEmptyString]
    public string[] Remove { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NAdd:
                {
                    Database.SetAdd(RKey, Abc.ToRedis(Add));
                }
                break;
            case NRemove:
                {
                    Database.SetRemove(RKey, Abc.ToRedis(Remove));
                }
                break;
            default:
                {
                    Database.KeyDelete(RKey);
                    Database.SetAdd(RKey, Abc.ToRedis(Value));
                }
                break;
        }
    }
}
