using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Rename", "RedisKey")]
[OutputType(typeof(bool))]
public sealed class RenameKeyCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public string NewKey { get; set; }

    [Parameter]
    public When When { set => _When = value; }
    When? _When;

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        bool res = Database.KeyRename(RKey, NewKey, _When ?? When.Always);
        if (_When.HasValue)
            WriteObject(res);
    }
}
