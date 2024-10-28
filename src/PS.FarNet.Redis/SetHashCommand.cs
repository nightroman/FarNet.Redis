using StackExchange.Redis;
using System.Collections;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisHash", DefaultParameterSetName = NMain)]
public sealed class SetHashCommand : BaseKeyCmdlet
{
    const string NMany = "Many";
    const string NRemove = "Remove";
    const string NIncrement = "Increment";
    const string NDecrement = "Decrement";
    const string NAdd = "Add";
    const string NSubtract = "Subtract";

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NIncrement)]
    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NDecrement)]
    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NAdd)]
    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NSubtract)]
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

    [Parameter(Mandatory = true, ParameterSetName = NIncrement)]
    public long Increment { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NDecrement)]
    public long Decrement { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NAdd)]
    public double Add { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NSubtract)]
    public double Subtract { get; set; }

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
            case NIncrement:
                {
                    long res = Database.HashIncrement(RKey, Field, Increment);
                    WriteObject(res);
                }
                break;
            case NDecrement:
                {
                    long res = Database.HashDecrement(RKey, Field, Decrement);
                    WriteObject(res);
                }
                break;
            case NAdd:
                {
                    double res = Database.HashIncrement(RKey, Field, Add);
                    WriteObject(res);
                }
                break;
            case NSubtract:
                {
                    double res = Database.HashDecrement(RKey, Field, Subtract);
                    WriteObject(res);
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
