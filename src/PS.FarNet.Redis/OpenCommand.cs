using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Open", "Redis")]
[OutputType(typeof(IDatabase))]
public sealed class OpenCommand : PSCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    public string Configuration { get; set; }

    protected override void BeginProcessing()
    {
        var db = DB.Open(Configuration);
        WriteObject(db);
    }
}
