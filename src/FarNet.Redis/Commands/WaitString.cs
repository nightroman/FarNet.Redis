using System.Diagnostics;

namespace FarNet.Redis.Commands;

public sealed class WaitString : BaseKeyCommand
{
    // required
    public required TimeSpan Delay { get; init; }
    public required TimeSpan Timeout { get; init; }

    // result
    public string? Result { get; private set; }

    protected override void Validate()
    {
        AssertDelayTimeout(Delay, Timeout);
    }

    protected override void Execute()
    {
        var sw = Stopwatch.StartNew();
        while (true)
        {
            var res = Database.StringGet(Key);
            if (!res.IsNull)
            {
                Result = res;
                return;
            }

            if (sw.Elapsed >= Timeout)
                return;

            Thread.Sleep(Delay);
        }
    }
}
