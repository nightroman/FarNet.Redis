using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseKeysCmdlet : BaseDBCmdlet
{
    [Parameter(Position = 0, Mandatory = true)]
    [ValidateCount(1, int.MaxValue)]
    public string[] Key { get; set; }
}
