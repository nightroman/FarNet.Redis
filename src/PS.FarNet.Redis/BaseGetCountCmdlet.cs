using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseGetCountCmdlet : BaseKeyCmdlet
{
    protected const string NCount = "Count";

    [Parameter(ParameterSetName = NCount, Mandatory = true)]
    public SwitchParameter Count { get; set; }
}
