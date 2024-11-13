[NuGet]: https://www.nuget.org/packages/FarNet.Redis
[GitHub]: https://github.com/nightroman/FarNet.Redis
[Microsoft.Garnet]: https://microsoft.github.io/garnet
[StackExchange.Redis]: https://github.com/StackExchange/StackExchange.Redis
[GarnetServer]: https://github.com/nightroman/FarNet.Redis/tree/main/src/GarnetServer

# FarNet.Redis

[StackExchange.Redis] PowerShell module and FarNet library

The module provides PowerShell friendly wrappers for the basic SERedis API.
For not yet implemented or planned, e.g. getting `byte[]` data or building
transactions, use SERedis API directly, see tests.

Redis keys, simple output values, and complex type items are strings.\
Input values may be anything supported by SERedis, including `byte[]`.

Packages:
- PowerShell 7.4 module, PSGallery [FarNet.Redis](https://www.powershellgallery.com/packages/FarNet.Redis)
- FarNet library, NuGet [FarNet.Redis](https://www.nuget.org/packages/FarNet.Redis)

## PowerShell module

You may install the PowerShell module by this command:

```powershell
Install-Module -Name FarNet.Redis
```

Explore, see also [about_FarNet.Redis.help.txt](https://github.com/nightroman/FarNet.Redis/blob/main/src/Content/about_FarNet.Redis.help.txt):

```powershell
# import and get module commands
Import-Module -Name FarNet.Redis
Get-Command -Module FarNet.Redis

# get module and commands help
help about_FarNet.Redis
help Open-Redis
help Set-RedisString
help Get-RedisString
...
```

## FarNet library

To install as the FarNet library `FarNet.Redis`, follow [these steps](https://github.com/nightroman/FarNet#readme).\
See [PowerShell FarNet modules](https://github.com/nightroman/FarNet/wiki/PowerShell-FarNet-modules) for details.

See also [FarNet.RedisKit](https://www.nuget.org/packages/FarNet.RedisKit),
the module for managing Redis data in Far Manager.

## Examples

See [tests](https://github.com/nightroman/FarNet.Redis/tree/main/tests) for all examples.

PowerShell

```powershell
Import-Module FarNet.Redis
$db = Open-Redis 127.0.0.1:3278
Set-RedisString test:key1 Hello
Get-RedisString test:key1
```

F#

```fsharp
open StackExchange.Redis
let db = DB.Open("127.0.0.1:3278")
db.StringSet("test:key1", "Hello")
db.StringGet("test:key1")
```

## Garnet server

[Microsoft.Garnet] is the Redis like server, especially useful on Windows.

Use a tiny project like [GarnetServer] to build and run the server.\
Or download ready to run binaries from [Garnet Releases](https://github.com/microsoft/garnet/releases).

## Known issues

[#61]: https://github.com/microsoft/garnet/issues/61
[#358]: https://github.com/microsoft/garnet/issues/358
[FAQ]: https://microsoft.github.io/garnet/docs/welcome/faq

For faster local connections, consider `127.0.0.1` instead of `localhost` in configuration strings.

Garnet: The only database is 0, see [#61]. Other database indexes formally work but 0 is used.

Garnet: The same key may simultaneously exist as string and object, see [#358].
Mind expected inconsistencies and not unique `Search-RedisKey` results.

Garnet: Do not use saved checkpoints with different server versions, format may change, see [FAQ].
To migrate data, use `Export-Redis`, delete checkpoints, upgrade server, use `Import-Redis`.

## See also

- [FarNet.Redis Release Notes](https://github.com/nightroman/FarNet.Redis/blob/main/Release-Notes.md)
- [StackExchange.Redis]
- [Microsoft.Garnet]
