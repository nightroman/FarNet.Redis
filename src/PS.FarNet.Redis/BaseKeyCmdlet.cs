using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseKeyCmdlet : BaseDBCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    public string Key
    {
        set { RKey = value; }
    }

    protected RedisKey RKey { get; set; }
}
