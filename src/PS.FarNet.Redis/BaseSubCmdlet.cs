using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseSubCmdlet : BaseDBCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    public RedisChannel Channel { get; set; }
}
