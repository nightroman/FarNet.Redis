using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Save", "Redis")]
public sealed class SaveCommand : BaseDBCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var options = ConfigurationOptions.Parse(Database.Multiplexer.Configuration);
        var allowAdmin = options.AllowAdmin;

        IConnectionMultiplexer redis = null;
        try
        {
            if (allowAdmin)
            {
                redis = Database.Multiplexer;
            }
            else
            {
                options.AllowAdmin = true;
                redis = ConnectionMultiplexer.Connect(options);
            }

            var server = DB.GetServer(redis, options);
            var lastSave = server.LastSave();

            server.Save(SaveType.BackgroundSave);
            while (true)
            {
                Thread.Sleep(200);
                var nextSave = server.LastSave();
                if (nextSave != lastSave)
                    break;
            }
        }
        finally
        {
            if (!allowAdmin)
                redis.Close();
        }
    }
}
