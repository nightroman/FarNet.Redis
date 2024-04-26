using StackExchange.Redis;
using System.Collections;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisHash", DefaultParameterSetName = NMain)]
public sealed class SetHashCommand : BaseKeyCmdlet
{
    const string NMany = "Many";
    const string NRemove = "Remove";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    public RedisValue Field { get; set; }

    [Parameter(Position = 2, Mandatory = true, ParameterSetName = NMain)]
    public RedisValue Value { get; set; }

    [Parameter(ParameterSetName = NMain)]
    public When When { set => _When = value; }
    When? _When;

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMany)]
    public IDictionary Many { set => _Many = value.ToHashEntryArray(); }
    HashEntry[] _Many;

    [Parameter(Mandatory = true, ParameterSetName = NRemove)]
    public RedisValue[] Remove { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NRemove:
                {
                    Database.HashDelete(RKey, Remove);
                }
                break;
            case NMany:
                {
                    Database.HashSet(RKey, _Many);
                }
                break;
            default:
                {
                    bool res = Database.HashSet(RKey, Field, Value, _When ?? When.Always);
                    if (_When.HasValue)
                        WriteObject(res);
                }
                break;
        }
    }
}
