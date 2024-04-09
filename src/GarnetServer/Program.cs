using Garnet;

try
{
    Console.WriteLine($"{DateTime.Now} server start");
    using var server = new GarnetServer(args);
    server.Start();
    Thread.Sleep(Timeout.Infinite);
}
catch (Exception ex)
{
    Console.WriteLine($"{DateTime.Now} server exception: {ex.Message}");
}
