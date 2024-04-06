using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisSet", DefaultParameterSetName = "Main")]
[OutputType(typeof(HashSet<string>))]
[OutputType(typeof(long))]
public sealed class GetSetCommand : BaseGetCountCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Count)
        {
            var res = Database.SetLength(RKey);
            WriteObject(res);
        }
        else
        {
            var res = Database.SetMembers(RKey);
            WriteObject(Abc.ToHashSet(res));
        }
    }
}
