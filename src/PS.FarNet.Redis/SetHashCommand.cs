using StackExchange.Redis;
using System.Collections;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisHash", DefaultParameterSetName = NMain)]
public sealed class SetHashCommand : BaseKeyCmdlet
{
    const string NDelete = "Delete";
    const string NSet = "Set";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    public IDictionary Value { set => _Value = value.ToHashEntryArray(); }
    HashEntry[] _Value;

    [Parameter(Mandatory = true, ParameterSetName = NDelete)]
    public string[] Delete { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NSet)]
    public IDictionary Set { set => _Set = value.ToHashEntryArray(); }
    HashEntry[] _Set;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NDelete:
                {
                    Database.HashDelete(RKey, Delete.ToRedisValueArray());
                }
                break;
            case NSet:
                {
                    Database.HashSet(RKey, _Set);
                }
                break;
            default:
                {
                    Database.KeyDelete(RKey);
                    Database.HashSet(RKey, _Value);
                }
                break;
        }
    }
}
