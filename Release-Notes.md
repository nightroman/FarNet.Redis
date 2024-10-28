# FarNet.Redis Release Notes

## v0.10.4

`Get-RedisHash`, `Get-RedisSet`: new parameter `Pattern`.

`Set-RedisHash`: new parameters `Increment`, `Decrement`, `Add`, `Subtract`.

## v0.10.3

`Export-Redis`
- New parameter `Exclude`
- Empty strings should be exported

## v0.10.2

Add `TimeToLive` to `Get-RedisString` (SETNX, Garnet 1.0.34).

Garnet 1.0.34

## v0.10.1

`Open-Redis`: new parameter `Prefix`.

## v0.10.0

New cmdlet `Use-RedisPrefix`.

Allow no keys for `Remove-RedisKey` and `Test-RedisKey`.

Garnet 1.0.33

## v0.9.0

New cmdlet `Rename-RedisKey`.

## v0.8.0

New cmdlet `Set-RedisNumber`, cleaner for number operations than `Set-RedisString`,
implements `Add`, `Subtract` (double) in addition to `Increment`, `Decrement` (long).

**Breaking** `Set-RedisString`: `Increment`, `Decrement` moved to `Set-RedisNumber`.

Garnet 1.0.32

## v0.7.11

StackExchange.Redis 2.8.16

Garnet 1.0.30

## v0.7.10

Garnet 1.0.19

## v0.7.9

`Open-Redis`: removed parameter `SyncTimeout`.

## v0.7.8

StackExchange.Redis 2.8.0

Garnet 1.0.14

## v0.7.7

`Export-Redis`: write more values as strings.

`Import-Redis`: support files with UTF8 BOM.

Garnet 1.0.9

## v0.7.6

`Export-Redis`: relax JSON escaping.

## v0.7.5

Use hashtable to return hashes instead of string dictionary.

Garnet 1.0.8

## v0.7.4

`Get-RedisList`, `Get-RedisSet`: unroll results to avoid adverse effects.

## v0.7.3

Add `Save-Redis`, use on stopping Garnet service.

## v0.7.2

Amend EOL treatment on `Export-Redis`, `Import-Redis`.

Retire aliases `-Expire` and `-Expiry`, use `-TimeToLive`.

## v0.7.1

Rename `-Expire` and `-Expiry` parameters to `-TimeToLive`. Old names still
work as aliases but will be removed soon.

`Search-RedisKey`: simple wildcard or glob-style depending on `[]`.

`Open-Redis`: new parameter `SyncTimeout`.

## v0.7.0

**Breaking changes**, simplify usage, align with SERedis methods

- `Get-RedisHash`, `Set-RedisList`, `Set-RedisSet` - amend parameters
- `Set-RedisHash` - rework parameters, add `When`

## v0.6.1

`$env:FARNET_REDIS_CONFIGURATION` is the default database configuration.
Used by `Open-Redis` when called without parameters and by other cmdlets.

## v0.6.0

New utilities `Export-Redis`, `Import-Redis`.

## v0.5.3

`Get-RedisHash`: new parameter `Field`.

## v0.5.2

`Open-Redis`: new switch `AllowAdmin`.

## v0.5.1

Minor tweaks, hints on using faster 127.0.0.1 instead of localhost.

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
