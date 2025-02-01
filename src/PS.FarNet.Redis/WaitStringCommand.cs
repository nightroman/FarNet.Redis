using FarNet.Redis.Commands;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Wait", "RedisString")]
[OutputType(typeof(string))]
public sealed class WaitStringCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public TimeSpan Delay { get; set; }

    [Parameter(Position = 2, Mandatory = true)]
    public TimeSpan Timeout { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var command = new WaitString
        {
            Database = Database,
            Key = RKey,
            Delay = Delay,
            Timeout = Timeout,
        };

        Invoke(command);

        WriteObject(command.Result);
    }
}
