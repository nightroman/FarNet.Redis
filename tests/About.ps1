Set-StrictMode -Version 3

Import-Module FarNet.Redis
$Global:db = Open-Redis 127.0.0.1:3278
