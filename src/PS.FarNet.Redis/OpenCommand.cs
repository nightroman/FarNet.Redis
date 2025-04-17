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

    void WriteDatabase(IDatabase db)
    {
        if (!string.IsNullOrEmpty(Prefix))
            db = db.WithKeyPrefix(Prefix);

        WriteObject(db);
    }

    protected override void BeginProcessing()
    {
        if (string.IsNullOrEmpty(Configuration))
            Configuration = DB.DefaultConfiguration;

        var db = DB.Open(Configuration, Index);
        WriteDatabase(db);
    }
}
