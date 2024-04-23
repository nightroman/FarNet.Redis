using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Import", "Redis")]
[OutputType(typeof(string))]
public sealed class ImportCommand : BaseDBCmdlet
{
    [Parameter(Position = 0)]
    public string Path { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        Path = GetUnresolvedProviderPathFromPSPath(Path);

        var command = new ImportJson(Path, Database);
        command.Invoke();
    }
}
