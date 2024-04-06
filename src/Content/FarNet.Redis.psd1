@{
	Author = 'Roman Kuzmin'
	ModuleVersion = '0.0.0'
	Description = 'FarNet.Redis cmdlets'
	Copyright = 'Copyright (c) Roman Kuzmin'
	GUID = '08fab1c4-7b7b-4467-91d0-a88fb123f9cc'

	PowerShellVersion = '7.4.1'
	RootModule = 'PS.FarNet.Redis.dll'
	RequiredAssemblies = 'FarNet.Redis.dll', 'StackExchange.Redis.dll'

	AliasesToExport = @()
	FunctionsToExport = @()
	VariablesToExport = @()
	CmdletsToExport = @(
		'Open-Redis'
		'Close-Redis'
		'Get-RedisAny'
		'Get-RedisHash'
		'Get-RedisKey'
		'Get-RedisList'
		'Get-RedisServer'
		'Get-RedisSet'
		'Get-RedisString'
		'Remove-RedisKey'
		'Search-RedisKey'
		'Set-RedisHash'
		'Set-RedisList'
		'Set-RedisSet'
		'Set-RedisString'
		'Test-RedisKey'
	)
}
