using StackExchange.Redis;

namespace FarNet.Redis.Commands;

public abstract class BaseDBCommand : AnyCommand
{
    public required IDatabase Database { get; init; }
}
