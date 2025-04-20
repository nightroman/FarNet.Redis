using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisServer")]
[OutputType(typeof(IServer))]
public sealed class GetServerCommand : BaseDBCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var server = DB.GetServer(Database);
        WriteObject(server);
    }
}
