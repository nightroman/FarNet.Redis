namespace FarNet.Redis.Tests;

public class TextTest : AbcTest
{
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
}
