using FarNet.Redis.Commands;
using StackExchange.Redis;
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
        set => _excludePatterns = value.Select(x => new WildcardPattern(x)).ToArray();
    }
    WildcardPattern[] _excludePatterns;

    [Parameter]
    public TimeSpan? TimeToLive { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        using var stream = new FileStream(GetUnresolvedProviderPathFromPSPath(Path), FileMode.Create);

        IEnumerable<RedisKey> keys = DB.Keys(Database, Pattern);
        if (_excludePatterns is { })
            keys = keys.Where(key => !_excludePatterns.Any(x => x.IsMatch(key)));

        var command = new ExportJson
        {
            Database = Database,
            Stream = stream,
            Keys = keys,
            TimeToLive = TimeToLive,
            WriteWarning = WriteWarning,
        };

        Invoke(command);
    }
}
