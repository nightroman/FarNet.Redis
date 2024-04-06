using StackExchange.Redis;
using System.Collections;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Set", "RedisHash")]
public sealed class SetHashCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    [ValidateNotNull]
    public IDictionary Value { get; set; }

    [Parameter]
    public SwitchParameter Update { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var entries = new HashEntry[Value.Count];
        var i = -1;
        foreach (DictionaryEntry kv in Value)
        {
            ++i;
            entries[i] = new(new RedisValue(kv.Key?.ToString()), new RedisValue(kv.Value?.ToString()));
        }

        if (!Update)
            Database.KeyDelete(RKey);

        Database.HashSet(RKey, entries);
    }
}
