using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseKeysCmdlet : BaseDBCmdlet
{
	//! Allow empty and null, do not require odd checks before calling.
	//! Instead, process null and none or fail when 1+ is needed.
    [Parameter(Position = 0, Mandatory = true)]
    [AllowEmptyCollection]
    [AllowNull]
    public string[] Key { get; set; }
}
