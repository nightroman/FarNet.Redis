using StackExchange.Redis;

namespace FarNet.Redis.Commands;

public abstract class BaseKeyCommand : BaseDBCommand
{
    public required RedisKey Key { get; init; }
}
