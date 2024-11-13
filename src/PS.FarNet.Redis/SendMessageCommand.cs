using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Send", "RedisMessage")]
[OutputType(typeof(long))]
public sealed class SendMessageCommand : BaseSubCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public RedisValue Message { get; set; }

    [Parameter]
    public SwitchParameter Result { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        long res = Database.Publish(Channel, Message);
        if (Result)
            WriteObject(res);
    }
}
