using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisString", DefaultParameterSetName = NMain)]
[OutputType(typeof(string))]
[OutputType(typeof(long))]
public sealed class GetStringCommand : BaseDBCmdlet
{
    const string NMany = "Many";
    const string NLength = "Length";

    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NMain)]
    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NLength)]
    public string Key { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NMany)]
    public string[] Many { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NLength)]
    public SwitchParameter Length { get; set; }

    [Parameter(ParameterSetName = NMain)]
    public TimeSpan? TimeToLive { set { _TimeToLive = value; _hasTimeToLive = true; } }
    TimeSpan? _TimeToLive;
    bool _hasTimeToLive;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NLength:
                {
                    long res = Database.StringLength(Key);
                    WriteObject(res);
                }
                break;
            case NMany:
                {
                    RedisValue[] res = Database.StringGet(Many.ToRedisKeyArray());
                    foreach (var item in res)
                        WriteObject((string)item);
                }
                break;
            default:
                {
                    if (_hasTimeToLive)
                    {
                        RedisValue res = Database.StringGetSetExpiry(Key, _TimeToLive);
                        WriteObject((string)res);
                    }
                    else
                    {
                        RedisValue res = Database.StringGet(Key);
                        WriteObject((string)res);
                    }
                }
                break;
        }
    }
}
