using StackExchange.Redis;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisHash", DefaultParameterSetName = NMain)]
[OutputType(typeof(Hashtable))]
[OutputType(typeof(string))]
[OutputType(typeof(long))]
[OutputType(typeof(TimeSpan))]
public sealed class GetHashCommand : BaseGetCountCmdlet
{
    const string NPattern = "Pattern";

    [Parameter(Position = 1, ParameterSetName = NMain)]
    [ValidateNotNullOrEmpty]
    public RedisValue[] Field { get; set; }

    [Parameter(ParameterSetName = NMain)]
    public SwitchParameter TimeToLive { get; set; }

    [Parameter(ParameterSetName = NPattern, Mandatory = true)]
    [AllowEmptyString]
    [AllowNull]
    public string Pattern { get; set; }

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
            case NPattern:
                {
                    if (Pattern is { })
                        Pattern = ConvertPatternToRedis(Pattern);

                    IEnumerable<HashEntry> res = Database.HashScan(RKey, RedisValue.Unbox(Pattern), 250, CommandFlags.None);
                    WriteObject(res.ToHashtable());
                }
                return;
        }

        if (TimeToLive)
        {
            long[] res = Database.HashFieldGetTimeToLive(RKey, Field);
            foreach (long ttl in res)
                WriteObject(ttl > 0 ? TimeSpan.FromMilliseconds(ttl) : new TimeSpan(ttl));

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
                WriteObject(res.ToHashtable());
        }
    }
}
