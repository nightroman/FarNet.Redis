using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Close", "Redis")]
public sealed class CloseCommand : BaseDBCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();
        DB.Close(Database);
    }
}
