using StackExchange.Redis;
using System.Management.Automation;
using System.Threading;

namespace PS.FarNet.Redis;

[Cmdlet("Save", "Redis")]
public sealed class SaveCommand : BaseDBCmdlet
{
    [Parameter(Position = 0)]
    public string Configuration { get; set; }

    protected override void BeginProcessing()
    {
        IConnectionMultiplexer redis;
        if (Configuration == null)
        {
            base.BeginProcessing();
            redis = Database.Multiplexer;
        }
        else
        {
            var options = ConfigurationOptions.Parse(Configuration);
            options.AllowAdmin = true;
            redis = ConnectionMultiplexer.Connect(options);
        }

        var server = redis.GetServers()[0];
        var lastSave = server.LastSave();

        server.Save(SaveType.BackgroundSave);
        while(true)
        {
            Thread.Sleep(200);
            var nextSave = server.LastSave();
            if (nextSave != lastSave)
                break;
        }
    }
}
