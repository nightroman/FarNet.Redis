using System;
using System.Diagnostics;
using System.Management.Automation;
using System.Threading;

namespace PS.FarNet.Redis;

[Cmdlet("Wait", "RedisString")]
[OutputType(typeof(string))]
public sealed class WaitStringCommand : BaseKeyCmdlet
{
    [Parameter(Position = 1, Mandatory = true)]
    public TimeSpan Delay { get; set; }

    [Parameter(Position = 2, Mandatory = true)]
    public TimeSpan Timeout { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Delay >= Timeout)
            throw new PSArgumentException("Parameter Delay must less than Timeout.");

        var sw = Stopwatch.StartNew();
        while (true)
        {
            var res = Database.StringGet(RKey);
            if (!res.IsNull)
            {
                WriteObject((string)res);
                return;
            }

            if (sw.Elapsed >= Timeout)
                return;

            Thread.Sleep(Delay);
        }
    }
}
