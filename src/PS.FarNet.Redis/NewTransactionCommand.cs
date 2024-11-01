using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("New", "RedisTransaction")]
[OutputType(typeof(ITransaction))]
public sealed class NewTransactionCommand : BaseDBCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        ITransaction trans = Database.CreateTransaction();
        WriteObject(trans);
    }
}
