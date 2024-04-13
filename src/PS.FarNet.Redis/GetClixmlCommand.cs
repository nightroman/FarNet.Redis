using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisClixml")]
[OutputType(typeof(object))]
public sealed class GetClixmlCommand : BaseKeyCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var res = Database.StringGet(RKey);
        if (res.HasValue)
        {
            var str = (string)res;
            var obj = PSSerializer.Deserialize(str);
            WriteObject(obj);
        }
    }
}
