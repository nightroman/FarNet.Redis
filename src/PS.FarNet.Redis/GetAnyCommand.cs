using StackExchange.Redis;
using System.Collections;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisAny")]
[OutputType(typeof(string))]
[OutputType(typeof(Hashtable))]
[OutputType(typeof(List<string>))]
[OutputType(typeof(HashSet<string>))]
public sealed class GetAnyCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1)]
    public RedisType Type { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Type == RedisType.None)
            Type = Database.KeyType(RKey);

        switch (Type)
        {
            case RedisType.String:
                {
                    RedisValue res = Database.StringGet(RKey);
                    WriteObject((string)res);
                }
                break;
            case RedisType.Hash:
                {
                    HashEntry[] res = Database.HashGetAll(RKey);
                    WriteObject(res.ToHashtable());
                }
                break;
            case RedisType.List:
                {
                    RedisValue[] res = Database.ListRange(RKey);
                    WriteObject(res.ToStringList());
                }
                break;
            case RedisType.Set:
                {
                    RedisValue[] res = Database.SetMembers(RKey);
                    WriteObject(res.ToStringHashSet());
                }
                break;
            case RedisType.None:
                {
                }
                break;
            default:
                {
                    throw new PSNotSupportedException($"Not supported Redis type: {Type}");
                }
        }
    }
}
