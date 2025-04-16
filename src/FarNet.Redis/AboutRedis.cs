using StackExchange.Redis;
using System.Text;

namespace FarNet.Redis;

public static class AboutRedis
{
    public class Exception(string message) : System.Exception(message) { }

    public static IServer GetServer(IConnectionMultiplexer redis, ConfigurationOptions? options = null)
    {
        options ??= ConfigurationOptions.Parse(redis.Configuration);
        return redis.GetServer(options.EndPoints[0]);
    }

    public static bool IsTextAscii(string value)
    {
        return value.All(x => x < 128);
    }

    public static object GetBlobOrText(RedisValue value)
    {
        var blob = (byte[])value!;
        var text = Encoding.UTF8.GetString(blob);
        if (IsTextAscii(text))
            return text;

        var temp = Encoding.UTF8.GetBytes(text);
        return blob.SequenceEqual(temp) ? text : blob;
    }

    public static string? GetLineText(RedisValue value)
    {
        var res = GetBlobOrText(value);
        if (res is not string text)
            return null;

        if (text.Contains('\n') || text.Contains('\r'))
            return null;

        return text;
    }

    public static string? HashToText(HashEntry[] items)
    {
        var sb = new StringBuilder();
        foreach (var item in items.OrderBy(x => x.Name))
        {
            var name = GetLineText(item.Name);
            if (name is null)
                return null;

            var value = GetLineText(item.Value);
            if (value is null)
                return null;

            if (sb.Length > 0)
                sb.AppendLine();

            sb.AppendLine(name).AppendLine(value);
        }
        return sb.ToString();
    }

    public static HashEntry[] TextToHash(IList<string> lines)
    {
        int n = lines.Count / 3;
        if (n * 3 != lines.Count)
            throw new Exception("Unexpected number of lines, should be multiple of 3.");

        var res = new HashEntry[n];
        for (int i = 0; i < n; ++i)
        {
            int k = i * 3;
            var name = lines[k].TrimEnd();
            if (name.Length == 0)
                throw new Exception($"Unexpected empty line {k + 1}.");

            var empty = lines[k + 2].TrimEnd();
            if (empty.Length > 0)
                throw new Exception($"Unexpected text line {k + 3}.");

            var value = lines[k + 1].TrimEnd();
            res[i] = new HashEntry(name, value);
        }
        return res;
    }

    public static string? ValuesToText(IEnumerable<RedisValue> items)
    {
        var sb = new StringBuilder();
        bool needsNewLine = false;
        foreach (var item in items)
        {
            var line = GetLineText(item);
            if (line is null)
                return null;

            if (needsNewLine)
                sb.AppendLine();
            else
                needsNewLine = true;

            sb.Append(line);
        }
        return sb.ToString();
    }
}
