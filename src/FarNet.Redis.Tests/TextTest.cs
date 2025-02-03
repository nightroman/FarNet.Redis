using StackExchange.Redis;

namespace FarNet.Redis.Tests;

public class TextTest : AbcTest
{
    static readonly string NL = Environment.NewLine;

    [Theory]
    [InlineData("Cg==", 1, '\n', 0)]
    [InlineData("DQ==", 1, '\r', 0)]
    [InlineData("AIA=", 2, 0, 128)]
    public void GetLineText_ko(string base64, int length, byte byte0, byte byte1)
    {
        var bytes = Convert.FromBase64String(base64);
        Assert.Equal(length, bytes.Length);
        Assert.Equal(byte0, bytes[0]);
        if (length > 1)
            Assert.Equal(byte1, bytes[1]);

        var res = AboutRedis.GetLineText(bytes);
        Assert.Null(res);
    }

    [Theory]
    [InlineData("CQ==", "\t")]
    public void GetLineText_ok(string base64, string text)
    {
        var bytes = Convert.FromBase64String(base64);
        var res = AboutRedis.GetLineText(bytes);
        Assert.Equal(text, res);
    }

    [Fact]
    public void HashRoundTripOrder()
    {
        var item1 = new HashEntry("q1", "v1");
        var item2 = new HashEntry("q2", "v2");

        // desc
        var items1 = new HashEntry[] { item2, item1 };

        var text = AboutRedis.HashToText(items1)!;
        var items2 = AboutRedis.TextToHash(text.Split(NL));

        // asc
        Assert.Equal(new HashEntry[] { item1, item2 }, items2);
    }

    [Fact]
    public void ValuesToText_head_empty()
    {
        var items = new RedisValue[] { "", "q1", "q2" };
        var text = AboutRedis.ValuesToText(items);
        Assert.Equal($"{NL}q1{NL}q2", text);
    }
}
