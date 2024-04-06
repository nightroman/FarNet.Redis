using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisList", DefaultParameterSetName = "Main")]
[OutputType(typeof(List<string>))]
[OutputType(typeof(long))]
public sealed class GetListCommand : BaseGetCountCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Count)
        {
            var res = Database.ListLength(RKey);
            WriteObject(res);
        }
        else
        {
            var res = Database.ListRange(RKey);
            WriteObject(Abc.ToList(res));
        }
    }
}
