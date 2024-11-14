using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Invoke", "RedisScript", DefaultParameterSetName = NMain)]
[OutputType(typeof(RedisResult))]
public sealed class InvokeScriptCommand : BaseDBCmdlet
{
    const string NLuaScript = "LuaScript";

    [Parameter(Position = 0, Mandatory = true, ParameterSetName = NMain)]
    public string Script { get; set; }

    [Parameter(ParameterSetName = NMain)]
    [AllowEmptyCollection]
    [AllowNull]
    public string[] Keys { get; set; }

    [Parameter(ParameterSetName = NMain)]
    [AllowEmptyCollection]
    [AllowNull]
    public RedisValue[] Argv { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = NLuaScript)]
    public object LuaScript
    {
        set
        {
            _LuaScript = value.ToBaseObject() switch
            {
                string str => StackExchange.Redis.LuaScript.Prepare(str),
                LuaScript lua => lua,
                _ => throw new PSArgumentException("Parameter LuaScript type should be 'string' or 'StackExchange.Redis.LuaScript'.")
            };
        }
    }
    LuaScript _LuaScript;

    [Parameter(ParameterSetName = NLuaScript)]
    public object Parameters { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        switch (ParameterSetName)
        {
            case NLuaScript:
                {
                    RedisResult res = Database.ScriptEvaluate(_LuaScript, Parameters.ToBaseObject());
                    WriteObject(res);
                }
                break;
            default:
                {
                    RedisResult res = Database.ScriptEvaluate(Script, Keys.ToRedisKeyArray(), Argv);
                    WriteObject(res);
                }
                break;
        }
    }
}
