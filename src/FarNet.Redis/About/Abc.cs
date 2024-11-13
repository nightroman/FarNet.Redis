using System.Linq;

namespace FarNet.Redis;

static class ExtensionMethods
{
    public static bool IsAscii(this string value)
    {
        return value.All(x => x < 128);
    }
}
