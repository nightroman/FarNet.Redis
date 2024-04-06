
Set-StrictMode -Version 3
Import-Module FarNet.Redis
$Global:db = Open-Redis localhost:3278
