using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Export", "Redis")]
[OutputType(typeof(string))]
public sealed class ExportCommand : BaseDBCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    public string Path { get; set; }

    [Parameter(Position = 1)]
    public string Pattern { get; set; }

    [Parameter]
    public TimeSpan? TimeToLive { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        Path = GetUnresolvedProviderPathFromPSPath(Path);

        var command = new ExportJson(Path, Database)
        {
            Pattern = Pattern,
            TimeToLive = TimeToLive,
            WriteWarning = WriteWarning,
        };
        command.Invoke();
    }
}
