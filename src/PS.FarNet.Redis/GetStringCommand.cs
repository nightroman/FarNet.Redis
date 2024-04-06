using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisString", DefaultParameterSetName = "Main")]
[OutputType(typeof(string))]
[OutputType(typeof(long))]
public sealed class GetStringCommand : BaseKeysCmdlet
{
    [Parameter(ParameterSetName = "Length", Mandatory = true)]
    public SwitchParameter Length { get; set; }

    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        if (Key.Length == 1)
        {
            if (Length)
            {
                var res = Database.StringLength(Key[0]);
                WriteObject(res);
            }
            else
            {
                var res = Database.StringGet(Key[0]);
                WriteObject((string)res);
            }
        }
        else
        {
            if (Length)
                throw new PSArgumentException("Length is not supported with key lists.");

            var res = Database.StringGet(Abc.ToKeys(Key));
            foreach (var item in res)
                WriteObject((string)item);
        }
    }
}
