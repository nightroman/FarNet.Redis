using FarNet.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Clear", "Redis")]
public sealed class ClearCommand : BaseDBCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var server = AboutRedis.GetServer(Database.Multiplexer);
        server.FlushDatabase(Database.Database);
    }
}
