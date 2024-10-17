using StackExchange.Redis;
using StackExchange.Redis.KeyspaceIsolation;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Use", "RedisPrefix")]
[OutputType(typeof(IDatabase))]
public sealed class UsePrefixCommand : BaseDBCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    public string Prefix { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        IDatabase res = Database.WithKeyPrefix(Prefix);
        WriteObject(res);
    }
}
