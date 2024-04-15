[NuGet]: https://www.nuget.org/packages/FarNet.Redis
[GitHub]: https://github.com/nightroman/FarNet.Redis
[Microsoft.Garnet]: https://microsoft.github.io/garnet
[StackExchange.Redis]: https://github.com/StackExchange/StackExchange.Redis
[GarnetServer]: https://github.com/nightroman/FarNet.Redis/tree/main/src/GarnetServer

# FarNet.Redis

[StackExchange.Redis] PowerShell module and FarNet library

The module provides PowerShell friendly wrappers for basic Redis types and
operations. For not yet implemented or advanced operations (like getting
`byte[]` data) use SERedis API methods directly, see examples in tests.

Redis keys, output simple values and complex type items are strings.\
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
The [NuGet package](https://www.nuget.org/packages/FarNet.Redis) is installed to `%FARHOME%\FarNet\Lib\FarNet.Redis`.

Included assets:

- `StackExchange.Redis.dll`, `FarNet.Redis.dll`

    General purpose Redis client and helper assemblies.\
    They are designed for using in C#, F#, PowerShell.

- `FarNet.Redis.psd1`, `PS.FarNet.Redis.dll`

    PowerShell module files.

- `FarNet.Redis.ini`

    F# scripts configuration, `FarNet.FSharpFar`.

The PowerShell module may be imported as:

```powershell
Import-Module $env:FARHOME\FarNet\Lib\FarNet.Redis
```

**Expose the module as a symbolic link or junction**

Consider exposing this module, so that you can:

```powershell
Import-Module FarNet.Redis
```

(1) Choose one of the module directories, see `$env:PSModulePath`.

(2) Change to the selected directory and create the symbolic link

```powershell
New-Item FarNet.Redis -ItemType SymbolicLink -Value $env:FARHOME\FarNet\Lib\FarNet.Redis
```

(3) Alternatively, you may create the similar folder junction point in Far
Manager using `AltF6`.

Then you may update the FarNet package with new versions. The symbolic link or
junction do not have to be updated, they point to the same location.

## Examples

See [tests](https://github.com/nightroman/FarNet.Redis/tree/main/tests) for all examples.

PowerShell

```powershell
Import-Module FarNet.Redis
$db = Open-Redis localhost:3278
Set-RedisString test:key1 Hello
Get-RedisString test:key1
```

F#

```fsharp
open StackExchange.Redis
let db = DB.Open("localhost:3278")
db.StringSet("test:key1", "Hello")
db.StringGet("test:key1")
```

## Garnet server

[Microsoft.Garnet] is the Redis like server, especially useful on Windows.

Use a simple console project like [GarnetServer] to run your own server.

## See also

- [FarNet.Redis Release Notes](https://github.com/nightroman/FarNet.Redis/blob/main/Release-Notes.md)
- [StackExchange.Redis]
- [Microsoft.Garnet]
