using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class BaseDBCmdlet : PSCmdlet
{
    protected const string NMain = "Main";

    [Parameter]
    public IDatabase Database { get; set; }

    protected override void BeginProcessing()
    {
        if (Database is null)
        {
            Database = GetVariableValue("db").ToBaseObject() as IDatabase;
            if (Database is null)
                throw new PSArgumentException("Expected variable $db or parameter Database.", nameof(Database));
        }
    }
}
