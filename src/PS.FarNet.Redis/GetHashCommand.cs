using StackExchange.Redis;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisHash", DefaultParameterSetName = NMain)]
[OutputType(typeof(Dictionary<string, string>))]
[OutputType(typeof(string))]
[OutputType(typeof(long))]
public sealed class GetHashCommand : BaseGetCountCmdlet
{
    [Parameter(Position = 1, ParameterSetName = NMain)]
    [ValidateNotNullOrEmpty]
    public RedisValue[] Field { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NCount:
                {
                    long res = Database.HashLength(RKey);
                    WriteObject(res);
                }
                return;
        }

        if (Field?.Length == 1)
        {
            RedisValue res = Database.HashGet(RKey, Field[0]);
            WriteObject((string)res);
        }
        else if (Field?.Length > 1)
        {
            RedisValue[] res = Database.HashGet(RKey, Field);
            foreach (var item in res)
                WriteObject((string)item);
        }
        else
        {
            HashEntry[] res = Database.HashGetAll(RKey);
            if (res.Length > 0)
                WriteObject(res.ToStringDictionary());
        }
    }
}
