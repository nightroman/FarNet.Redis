﻿using FarNet.Redis;
using StackExchange.Redis;
using System.Management.Automation;

namespace PS.FarNet.Redis;

[Cmdlet("Get", "RedisServer")]
[OutputType(typeof(IServer))]
public sealed class GetServerCommand : BaseDBCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();

        var server = AboutRedis.GetServer(Database.Multiplexer);

        WriteObject(server);
    }
}
