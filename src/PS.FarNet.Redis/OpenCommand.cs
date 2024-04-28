using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Open", "Redis", DefaultParameterSetName = NDefault)]
[OutputType(typeof(IDatabase))]
public sealed class OpenCommand : PSCmdlet
{
    const string NDefault = "Default";
    const string NConfiguration = "Configuration";

    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NConfiguration)]
    public string Configuration { get; set; }

    [Parameter(ParameterSetName = NConfiguration)]
    public SwitchParameter AllowAdmin { get; set; }

    [Parameter(ParameterSetName = NConfiguration)]
    public int SyncTimeout { get; set; }

    protected override void BeginProcessing()
    {
        switch (ParameterSetName)
        {
            case NDefault:
                {
                    var db = DB.OpenDefaultDatabase();
                    WriteObject(db);
                }
                break;
            case NConfiguration:
                {
                    var options = ConfigurationOptions.Parse(Configuration);
                    if (AllowAdmin)
                        options.AllowAdmin = true;

                    if (SyncTimeout > 0)
                        options.SyncTimeout = SyncTimeout;

                    var db = DB.Open(options);
                    WriteObject(db);
                }
                break;
        }
    }
}
