using FarNet.Redis.Commands;
using System;
using System.Linq;
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
    [SupportsWildcards]
    public string[] Exclude
    {
        set
        {
            _excludePatterns = value.Select(x => new WildcardPattern(x)).ToArray();
        }
    }
    WildcardPattern[] _excludePatterns;

    [Parameter]
    public TimeSpan? TimeToLive { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var command = new ExportJson
        {
            Database = Database,
            Path = GetUnresolvedProviderPathFromPSPath(Path),
            Pattern = Pattern,
            TimeToLive = TimeToLive,
            Exclude = _excludePatterns is null ? null : key => _excludePatterns.Any(x => x.IsMatch(key)),
            WriteWarning = WriteWarning,
        };

        Invoke(command);
    }
}
