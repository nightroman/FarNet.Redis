using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Clear", "Redis")]
public sealed class ClearCommand : BaseDBCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var server = DB.GetServer(Database);
        server.FlushDatabase(Database.Database);
    }
}
