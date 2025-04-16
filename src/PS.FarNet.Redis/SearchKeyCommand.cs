using FarNet.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Search", "RedisKey")]
[OutputType(typeof(string))]
public sealed class SearchKeyCommand : BaseDBCmdlet
{
    [Parameter(Position = 0)]
    public string Pattern { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Pattern is { })
            Pattern = ConvertPatternToRedis(Pattern);

        var server = AboutRedis.GetServer(Database.Multiplexer);
        var keys = server.Keys(Database.Database, Pattern);
        foreach (var key in keys)
            WriteObject((string)key);
    }
}
