using StackExchange.Redis;
using StackExchange.Redis.KeyspaceIsolation;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Open", "Redis", DefaultParameterSetName = NMain)]
[OutputType(typeof(IDatabase))]
public sealed class OpenCommand : PSCmdlet
{
    const string NMain = "Main";
    const string NConfiguration = "Configuration";

    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NConfiguration)]
    public string Configuration { get; set; }

    [Parameter]
    public string Prefix { get; set; }

    [Parameter(ParameterSetName = NConfiguration)]
    public SwitchParameter AllowAdmin { get; set; }

    void WriteDatabase(IDatabase db)
    {
        if (!string.IsNullOrEmpty(Prefix))
            db = db.WithKeyPrefix(Prefix);

        WriteObject(db);
    }

    protected override void BeginProcessing()
    {
        switch (ParameterSetName)
        {
            case NMain:
                {
                    var db = DB.OpenDefaultDatabase();
                    WriteDatabase(db);
                }
                break;
            case NConfiguration:
                {
                    var options = ConfigurationOptions.Parse(Configuration);
                    if (AllowAdmin)
                        options.AllowAdmin = true;

                    var db = DB.Open(options);
                    WriteDatabase(db);
                }
                break;
        }
    }
}
