using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Invoke", "RedisTransaction")]
[OutputType(typeof(bool))]
public sealed class InvokeTransactionCommand : PSCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    public ITransaction Transaction { get; set; }

    protected override void BeginProcessing()
    {
        bool res = Transaction.Execute(CommandFlags.None);
        WriteObject(res);
    }
}
