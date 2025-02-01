using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisNumber", DefaultParameterSetName = NMain)]
[OutputType(typeof(long))]
[OutputType(typeof(double))]
[OutputType(typeof(bool))]
public sealed class SetNumberCommand : BaseDBCmdlet
{
    const string NIncrement = "Increment";
    const string NDecrement = "Decrement";
    const string NAdd = "Add";
    const string NSubtract = "Subtract";

    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NMain)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NIncrement)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NDecrement)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NAdd)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NSubtract)]
    public string Key { get; set; }

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    public double Value { get; set; }

    [Parameter(ParameterSetName = NMain)]
    public TimeSpan? TimeToLive { get; set; }

    [Parameter(ParameterSetName = NMain)]
    public When When { set => _When = value; }
    When? _When;

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
            case NIncrement:
                {
                    long res = Database.StringIncrement(Key, Increment);
                    WriteObject(res);
                }
                break;
            case NDecrement:
                {
                    long res = Database.StringDecrement(Key, Decrement);
                    WriteObject(res);
                }
                break;
            case NAdd:
                {
                    double res = Database.StringIncrement(Key, Add);
                    WriteObject(res);
                }
                break;
            case NSubtract:
                {
                    double res = Database.StringDecrement(Key, Subtract);
                    WriteObject(res);
                }
                break;
            default:
                {
                    bool res = Database.StringSet(Key, Value, TimeToLive, false, _When ?? When.Always);
                    if (_When.HasValue)
                        WriteObject(res);
                }
                break;
        }
    }
}
