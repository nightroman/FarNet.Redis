using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisString", DefaultParameterSetName = "Main")]
[OutputType(typeof(long))]
[OutputType(typeof(double))]
[OutputType(typeof(string))]
public sealed class SetStringCommand : BaseKeysCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    [AllowNull]
    [AllowEmptyString]
    public string[] Value { get; set; }

    [Parameter(ParameterSetName = "Main")]
    [Parameter(ParameterSetName = "Get")]
    public TimeSpan? Expiry { get; set; }

    [Parameter(ParameterSetName = "When", Mandatory = true)]
    public When When { set => _When = value; }
    When? _When;

    [Parameter(ParameterSetName = "Append", Mandatory = true)]
    public SwitchParameter Append { get; set; }

    [Parameter(ParameterSetName = "Decrement", Mandatory = true)]
    public SwitchParameter Decrement { get; set; }

    [Parameter(ParameterSetName = "Increment", Mandatory = true)]
    public SwitchParameter Increment { get; set; }

    [Parameter(ParameterSetName = "Get", Mandatory = true)]
    public SwitchParameter Get { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Value == null)
            Value = Abc.OneNullString;

        if (Key.Length != Value.Length)
            throw new PSArgumentException("Expected the same number of Key and Value items.");

        if (Key.Length == 1)
        {
            if (Append)
            {
                var res = Database.StringAppend(Key[0], Value[0]);
                WriteObject(res);
            }
            else if (Decrement)
            {
                var res = Database.Execute("DECRBY", Key[0], Value[0]);
                WriteObject((double)res);
            }
            else if (Increment)
            {
                var res = Database.Execute("INCRBY", Key[0], Value[0]);
                WriteObject((double)res);
            }
            else if (Get)
            {
                var res = Database.StringSetAndGet(Key[0], Value[0], Expiry);
                WriteObject((string)res);
            }
            else
            {
                var res = Database.StringSet(Key[0], Value[0], Expiry, false, _When ?? When.Always);
                if (_When.HasValue)
                    WriteObject(res);
            }
        }
        else
        {
            if (Append)
                throw new PSArgumentException("Append is not supported with key lists.");

            if (Decrement)
                throw new PSArgumentException("Decrement is not supported with key lists.");

            if (Increment)
                throw new PSArgumentException("Increment is not supported with key lists.");

            if (Get)
                throw new PSArgumentException("Get is not supported with key lists.");

            if (Expiry.HasValue)
                throw new PSArgumentException("Expiry is not supported with key lists.");

            var entries = new KeyValuePair<RedisKey, RedisValue>[Key.Length];
            for (int i = 0; i < Key.Length; ++i)
                entries[i] = new(Key[i], Value[i]);

            var res = Database.StringSet(entries, _When ?? When.Always);
            if (_When.HasValue)
                WriteObject(res);
        }
    }
}
