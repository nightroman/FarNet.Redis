using StackExchange.Redis;
using System.Diagnostics;

namespace FarNet.Redis.Commands;

public sealed class UseLock : BaseKeyCommand
{
    // required
    public required RedisValue Value { get; init; }
    public required TimeSpan Delay { get; init; }
    public required TimeSpan Timeout { get; init; }
    public required Action Action { get; init; }

    Exception? _exception;

    protected override void Validate()
    {
        AssertDelayTimeout(Delay, Timeout);
    }

    protected override void Execute()
    {
        var sw = Stopwatch.StartNew();
        while (!Database.LockTake(Key, Value, Timeout))
        {
            if (sw.Elapsed >= Timeout)
                throw new TimeoutException($"Cannot take lock '{Key}', timeout {Timeout}.");

            Thread.Sleep(Delay);
        }

        CancellationTokenSource tokenSource = new();
        try
        {
            _ = Extend(tokenSource.Token);

            Action();
        }
        finally
        {
            tokenSource.Cancel();

            if (!Database.LockRelease(Key, Value) && _exception is null)
                _exception = new InvalidOperationException($"Cannot release lock '{Key}'.");
        }

        if (_exception is { })
            throw _exception;
    }

    async Task Extend(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
        {
            await Task.Delay(Timeout / 2, cancellationToken);

            try
            {
                if (!Database.LockExtend(Key, Value, Timeout))
                    throw new InvalidOperationException($"Cannot extend lock '{Key}'.");
            }
            catch (Exception ex)
            {
                _exception = ex;
                return;
            }
        }
    }
}
