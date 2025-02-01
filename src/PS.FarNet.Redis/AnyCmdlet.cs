using FarNet.Redis.Commands;
using System.Management.Automation;

namespace PS.FarNet.Redis;

public abstract class AnyCmdlet : PSCmdlet
{
    protected void WriteException(Exception exception, object target)
    {
        WriteError(new ErrorRecord(exception, exception.GetType().Name, ErrorCategory.NotSpecified, target));
    }

    protected void Invoke(AnyCommand command)
    {
        command.Assert();

        try
        {
            command.Invoke();
        }
        catch (RuntimeException)
        {
            // script failed
            throw;
        }
        catch (Exception ex)
        {
            // command failed
            WriteException(ex, null);
        }
    }
}
