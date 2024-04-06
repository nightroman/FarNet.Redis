using StackExchange.Redis;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisAny")]
[OutputType(typeof(string))]
[OutputType(typeof(List<string>))]
[OutputType(typeof(HashSet<string>))]
[OutputType(typeof(Dictionary<string, string>))]
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
            case RedisType.None:
            case RedisType.String:
                {
                    var res = Database.StringGet(RKey);
                    WriteObject((string)res);
                }
                break;

            case RedisType.Hash:
                {
                    var res = Database.HashGetAll(RKey);
                    WriteObject(Abc.ToDictionary(res));
                }
                break;

            case RedisType.List:
                {
                    var res = Database.ListRange(RKey);
                    WriteObject(Abc.ToList(res));
                }
                break;

            case RedisType.Set:
                {
                    var res = Database.SetMembers(RKey);
                    WriteObject(Abc.ToHashSet(res));
                }
                break;
        }
    }
}
