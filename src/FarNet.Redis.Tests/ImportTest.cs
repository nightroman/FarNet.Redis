using FarNet.Redis.Commands;
using System.Text;

namespace FarNet.Redis.Tests;

public class ImportTest : AbcTest
{
    [Theory]
    // bad root
    [InlineData("1", "JSON: Unexpected token 'Number'.")]
    [InlineData("{1}", """JSON: '1' is an invalid start of a property name. Expected a '"'. LineNumber: 0 | BytePositionInLine: 1.""")]
    // simple text
    [InlineData("""{"try:k1": "ok"}""", null)]
    [InlineData("""{"try:k1": 1}""", """JSON: try:k1: Unexpected token 'Number'.""")]
    // simple blob
    [InlineData("""{"try:k1": ["AIA="]}""", null)]
    [InlineData("""{"try:k1": ["bad"]}""", """JSON: try:k1: Cannot decode JSON text that is not encoded as valid Base64 to bytes.""")]
    [InlineData("""{"try:k1": [1]}""", """JSON: try:k1: Unexpected token 'Number'.""")]
    // complex bad
    [InlineData("""{"try:k1": {"Bad": 1}}""", """JSON: try:k1/Bad: Unexpected property 'Bad'.""")]
    [InlineData("""{"try:k1": {"EOL": 1}}""", """JSON: try:k1/EOL: Unexpected token 'Number'.""")]
    [InlineData("""{"try:k1": {"EOL": "bad"}}""", """JSON: try:k1/EOL: The string 'bad' was not recognized as a valid DateTime. There is an unknown word starting at index '0'.""")]
    // complex noop
    [InlineData("""{"try:k1": {"EOL": "9999-01-01"}}""", null)]
    // complex text
    [InlineData("""{"try:k1": {"Text": "ok"}}""", null)]
    [InlineData("""{"try:k1": {"Text": 1}}""", """JSON: try:k1/Text: Unexpected token 'Number'.""")]
    // complex blob
    [InlineData("""{"try:k1": {"Blob": "AIA="}}""", null)]
    [InlineData("""{"try:k1": {"Blob": 1}}""", """JSON: try:k1/Blob: Unexpected token 'Number'.""")]
    // list
    [InlineData("""{"try:k1": {"List": ["ok", "AIA="]}}""", null)]
    [InlineData("""{"try:k1": {"List": 1}}""", """JSON: try:k1/List: Unexpected token 'Number'.""")]
    [InlineData("""{"try:k1": {"List": [1]}}""", """JSON: try:k1/List: Unexpected token 'Number'.""")]
    // set
    [InlineData("""{"try:k1": {"Set": ["ok", ["AIA="]]}}""", null)]
    [InlineData("""{"try:k1": {"Set": 1}}""", """JSON: try:k1/Set: Unexpected token 'Number'.""")]
    [InlineData("""{"try:k1": {"Set": [1]}}""", """JSON: try:k1/Set: Unexpected token 'Number'.""")]
    // simple hash field
    [InlineData("""{"try:k1": {"Hash": {"f1": "ok", "f2": ["AIA="]}}}""", null)]
    [InlineData("""{"try:k1": {"Hash": {"f1": 1}}}""", """JSON: try:k1/Hash/f1: Unexpected token 'Number'.""")]
    [InlineData("""{"try:k1": {"Hash": {"f1": ["bad"]}}}""", """JSON: try:k1/Hash/f1: Cannot decode JSON text that is not encoded as valid Base64 to bytes.""")]
    // complex hash field
    [InlineData("""{"try:k1": {"Hash": {"f1": {"Bad": 1}}}}""", """JSON: try:k1/Hash/f1: Unexpected property 'Bad'.""")]
    [InlineData("""{"try:k1": {"Hash": {"f1": {"EOL": "9999-01-01"}}}}""", """JSON: try:k1/Hash/f1: Missing expected value.""")]
    [InlineData("""{"try:k1": {"Hash": {"f1": {"Text": "ok"}}}}""", null)]
    [InlineData("""{"try:k1": {"Hash": {"f1": {"Text": 1}}}}""", """JSON: try:k1/Hash/f1: Unexpected token 'Number'.""")]
    [InlineData("""{"try:k1": {"Hash": {"f1": {"Blob": "AIA="}}}}""", null)]
    [InlineData("""{"try:k1": {"Hash": {"f1": {"Blob": 1}}}}""", """JSON: try:k1/Hash/f1: Unexpected token 'Number'.""")]
    [InlineData("""{"try:k1": {"Hash": {"f1": {"Blob": "bad"}}}}""", """JSON: try:k1/Hash/f1: Cannot decode JSON text that is not encoded as valid Base64 to bytes.""")]
    public void Errors(string json, string? error)
    {
        var stream = new MemoryStream(Encoding.UTF8.GetBytes(json));
        var command = new ImportJson { Database = Database, Stream = stream };

        if (error is null)
        {
            command.Invoke();
        }
        else
        {
            var ex = Assert.Throws<InvalidOperationException>(command.Invoke);
            Assert.Equal(error, ex.Message);
        }

        Database.KeyDelete("try:k1");
    }
}
