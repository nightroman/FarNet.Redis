using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseGetCountCmdlet : BaseKeyCmdlet
{
    [Parameter(ParameterSetName = "Count", Mandatory = true)]
    public SwitchParameter Count { get; set; }
}
