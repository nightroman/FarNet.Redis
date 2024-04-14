using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisHash", DefaultParameterSetName = NMain)]
[OutputType(typeof(Dictionary<string, string>))]
[OutputType(typeof(long))]
public sealed class GetHashCommand : BaseGetCountCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Count)
        {
            var res = Database.HashLength(RKey);
            WriteObject(res);
        }
        else
        {
            var res = Database.HashGetAll(RKey);
            WriteObject(Abc.ToDictionary(res));
        }
    }
}
