using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseDBCmdlet : AnyCmdlet
{
    protected const string NMain = "Main";

    [Parameter]
    public IDatabase Database { get; set; }

    protected override void BeginProcessing()
    {
        if (Database is { })
            return;

        // get $db or default
        Database = GetVariableValue("db").ToBaseObject() as IDatabase ?? DB.Open(DB.DefaultConfiguration);
    }

    protected static string ConvertPatternToRedis(string pattern)
    {
        if (pattern.Contains('[') || pattern.Contains(']'))
            return pattern;
        else
            return pattern.Replace("\\", "\\\\");
    }
}
