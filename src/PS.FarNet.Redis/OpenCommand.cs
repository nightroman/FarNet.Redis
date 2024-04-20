using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Open", "Redis")]
[OutputType(typeof(IDatabase))]
public sealed class OpenCommand : PSCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    public string Configuration { get; set; }

    [Parameter]
    public SwitchParameter AllowAdmin { get; set; }

    protected override void BeginProcessing()
    {
        var options = ConfigurationOptions.Parse(Configuration);
        if (AllowAdmin)
            options.AllowAdmin = true;

        var db = DB.Open(options);
        WriteObject(db);
    }
}
