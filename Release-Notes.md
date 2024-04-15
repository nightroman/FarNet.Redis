# FarNet.Redis Release Notes

## v0.5.0

Cmdlets value parameters use `object` instead of `string` and support `byte[]` values.
Output still uses strings. Use SERedis methods to get `byte[]` results, e.g.:

    [byte[]]$db.StringGet(..)

See test tasks `bytes` for examples of using `byte[]`.

`Get-RedisString`, potentially breaking change
- `-Key` is `string`, not `string[]`
- use `-Many` for getting 2+ strings

## v0.4.0

Potentially breaking changes in cmdlet parameters.

Add new operation parameters, rework parameters.

## v0.3.0

New cmdlet `Set-RedisKey`.

New utility cmdlets `Get-RedisClixml`, `Set-RedisClixml`.

## v0.2.0

New utility cmdlet `Wait-RedisString`.

## v0.1.0

New cmdlets `Register-RedisSub`, `Unregister-RedisSub`.

## v0.0.3

Fix `Value` validation in `Set-RedisList`, `Set-RedisSet`.

## v0.0.2

PowerShell module and NuGet package.
