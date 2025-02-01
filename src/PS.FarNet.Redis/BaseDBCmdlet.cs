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
        Database = GetVariableValue("db").ToBaseObject() as IDatabase ?? DB.DefaultDatabase;
        if (Database is { })
            return;

        // can open default?
        if (Environment.GetEnvironmentVariable("FARNET_REDIS_CONFIGURATION") == null)
            throw new PSArgumentException("Requires parameter Database or variable $db or $env:FARNET_REDIS_CONFIGURATION.", nameof(Database));

        try
        {
            Database = DB.OpenDefaultDatabase();
        }
        catch (Exception ex)
        {
            throw new PSArgumentException($"Cannot connect Redis specified by $env:FARNET_REDIS_CONFIGURATION: {ex.Message}", ex);
        }
    }

    protected static string ConvertPatternToRedis(string pattern)
    {
        if (pattern.Contains('[') || pattern.Contains(']'))
            return pattern;
        else
            return pattern.Replace("\\", "\\\\");
    }
}
