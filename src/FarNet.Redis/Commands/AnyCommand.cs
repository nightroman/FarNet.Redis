namespace FarNet.Redis.Commands;

public abstract class AnyCommand
{
    bool _doneAssert;
    bool _doneInvoke;

    public void Assert()
    {
        _doneAssert = true;
        Validate();
    }

    public void Invoke()
    {
        if (_doneInvoke)
            throw new InvalidOperationException("Command cannot be invoked twice.");

        _doneInvoke = true;

        if (!_doneAssert)
            Validate();

        Execute();
    }

    protected abstract void Execute();

    protected virtual void Validate()
    {
    }

    protected static void AssertDelayTimeout(TimeSpan Delay, TimeSpan Timeout)
    {
        if (Delay >= Timeout)
            throw new ArgumentException("Delay must be less than timeout.");
    }
}
