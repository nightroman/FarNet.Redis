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
    public object Value { set => _Value = value.ToRedisValue(); }
    RedisValue _Value;

    [Parameter(Mandatory = true, ParameterSetName = NMany)]
    public IDictionary Many { get; set; }

    [Parameter(ParameterSetName = NMain)]
    [Parameter(ParameterSetName = NSetAndGet)]
    public TimeSpan? TimeToLive { get; set; }

    [Parameter(ParameterSetName = NMain)]
    [Parameter(ParameterSetName = NMany)]
    public When When { set => _When = value; }
    When? _When;

    [Parameter(Mandatory = true, ParameterSetName = NAppend)]
    public object Append { set => _Append = value.ToRedisValue(); }
    RedisValue _Append;

    [Parameter(Mandatory = true, ParameterSetName = NIncrement)]
    public long Increment { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NDecrement)]
    public long Decrement { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NSetAndGet)]
    [AllowEmptyString]
    [AllowNull]
    public object SetAndGet { set => _SetAndGet = value.ToRedisValue(); }
    RedisValue _SetAndGet;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NAppend:
                {
                    long res = Database.StringAppend(Key, _Append);
                    WriteObject(res);
                }
                break;
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
            case NSetAndGet:
                {
                    RedisValue res = Database.StringSetAndGet(Key, _SetAndGet, TimeToLive);
                    WriteObject((string)res);
                }
                break;
            case NMany:
                {
                    bool res = Database.StringSet(Many.ToRedisKeyValuePairArray(), _When ?? When.Always);
                    if (_When.HasValue)
                        WriteObject(res);
                }
                break;
            default:
                {
                    bool res = Database.StringSet(Key, _Value, TimeToLive, false, _When ?? When.Always);
                    if (_When.HasValue)
                        WriteObject(res);
                }
                break;
        }
    }
}
