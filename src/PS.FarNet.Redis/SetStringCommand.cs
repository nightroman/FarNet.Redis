using StackExchange.Redis;
using System;
using System.Collections;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisString", DefaultParameterSetName = NMain)]
[OutputType(typeof(long))]
[OutputType(typeof(double))]
[OutputType(typeof(string))]
public sealed class SetStringCommand : BaseDBCmdlet
{
    const string NMany = "Many";
    const string NAppend = "Append";
    const string NIncrement = "Increment";
    const string NDecrement = "Decrement";
    const string NSetAndGet = "SetAndGet";

    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NMain)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NAppend)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NIncrement)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NDecrement)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NSetAndGet)]
    public string Key { get; set; }

    [Parameter(Position = 1, Mandatory = true, ParameterSetName = NMain)]
    [AllowEmptyString]
    [AllowNull]
    public string Value { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NMany)]
    public IDictionary Many { get; set; }

    [Parameter(ParameterSetName = NMain)]
    [Parameter(ParameterSetName = NSetAndGet)]
    public TimeSpan? Expiry { get; set; }

    [Parameter(ParameterSetName = NMain)]
    [Parameter(ParameterSetName = NMany)]
    public When When { set => _When = value; }
    When? _When;

    [Parameter(Mandatory = true, ParameterSetName = NAppend)]
    public string Append { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NIncrement)]
    public long Increment { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NDecrement)]
    public long Decrement { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NSetAndGet)]
    [AllowEmptyString]
    [AllowNull]
    public string SetAndGet { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NAppend:
                {
                    var res = Database.StringAppend(Key, Append);
                    WriteObject(res);
                }
                break;
            case NIncrement:
                {
                    var res = Database.StringIncrement(Key, Increment);
                    WriteObject(res);
                }
                break;
            case NDecrement:
                {
                    var res = Database.StringDecrement(Key, Decrement);
                    WriteObject(res);
                }
                break;
            case NSetAndGet:
                {
                    var res = Database.StringSetAndGet(Key, SetAndGet, Expiry);
                    WriteObject((string)res);
                }
                break;
            case NMany:
                {
                    var res = Database.StringSet(Abc.ToRedisPairs(Many), _When ?? When.Always);
                    if (_When.HasValue)
                        WriteObject(res);
                }
                break;
            default:
                {
                    var res = Database.StringSet(Key, Value, Expiry, false, _When ?? When.Always);
                    if (_When.HasValue)
                        WriteObject(res);
                }
                break;
        }
    }
}
