using System;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisKey")]
public sealed class SetKeyCommand : BaseKeyCmdlet
{
    const string NExpire = "Expire";

    [Parameter(Mandatory = true, ParameterSetName = NExpire)]
    [AllowNull]
    public TimeSpan? Expire { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NExpire:
                {
                    Database.KeyExpire(RKey, Expire);
                }
                break;
        }
    }
}
