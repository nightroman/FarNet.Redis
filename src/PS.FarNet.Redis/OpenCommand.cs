using StackExchange.Redis;
using StackExchange.Redis.KeyspaceIsolation;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Open", "Redis")]
[OutputType(typeof(IDatabase))]
public sealed class OpenCommand : PSCmdlet
{
    [Parameter(Position = 0)]
    public string Configuration { get; set; }

    //! `DB` cannot be used due to alias `db` for `Debug`.
    [Parameter]
    public int Index { get; set; } = -1;

    [Parameter]
    public string Prefix { get; set; }

    [Parameter]
    public SwitchParameter AllowAdmin { get; set; }

    void WriteDatabase(IDatabase db)
    {
        if (!string.IsNullOrEmpty(Prefix))
            db = db.WithKeyPrefix(Prefix);

        WriteObject(db);
    }

    void Configure(ConfigurationOptions options)
    {
        if (AllowAdmin)
            options.AllowAdmin = true;
    }

    protected override void BeginProcessing()
    {
        if (string.IsNullOrEmpty(Configuration))
        {
            var db = DB.OpenDefaultDatabase(Configure);
            WriteDatabase(db);
        }
        else
        {
            var options = ConfigurationOptions.Parse(Configuration);
            Configure(options);

            var db = DB.Open(options, Index);
            WriteDatabase(db);
        }
    }
}
