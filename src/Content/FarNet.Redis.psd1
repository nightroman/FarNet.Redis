@{
	Author = 'Roman Kuzmin'
	ModuleVersion = '0.0.0'
	Description = 'StackExchange.Redis cmdlets'
	Copyright = 'Copyright (c) Roman Kuzmin'
	GUID = '08fab1c4-7b7b-4467-91d0-a88fb123f9cc'

	PowerShellVersion = '7.4.0'
	RootModule = 'PS.FarNet.Redis.dll'
	RequiredAssemblies = 'FarNet.Redis.dll', 'StackExchange.Redis.dll'

	AliasesToExport = @()
	FunctionsToExport = @()
	VariablesToExport = @()
	CmdletsToExport = @(
		'Open-Redis'
		'Save-Redis'
		'Close-Redis'
		'Get-RedisServer'
		'Use-RedisPrefix'

		'Get-RedisAny'
		'Get-RedisHash'
		'Get-RedisList'
		'Get-RedisSet'
		'Get-RedisString'

		'Set-RedisHash'
		'Set-RedisList'
		'Set-RedisNumber'
		'Set-RedisSet'
		'Set-RedisString'

		'Get-RedisKey'
		'Set-RedisKey'
		'Test-RedisKey'
		'Remove-RedisKey'
		'Rename-RedisKey'
		'Search-RedisKey'

		'Add-RedisHandler'
		'Send-RedisMessage'
		'Remove-RedisHandler'

		'New-RedisTransaction'
		'Invoke-RedisTransaction'

		'Export-Redis'
		'Import-Redis'
		'Get-RedisClixml'
		'Set-RedisClixml'
		'Merge-RedisSet'
		'Use-RedisLock'
		'Wait-RedisString'
	)

	PrivateData = @{
		PSData = @{
			Tags = 'Redis', 'Client', 'Database'
			ProjectUri = 'https://github.com/nightroman/FarNet.Redis'
			LicenseUri = 'https://github.com/nightroman/FarNet.Redis/blob/main/LICENSE'
			ReleaseNotes = 'https://github.com/nightroman/FarNet.Redis/blob/main/Release-Notes.md'
		}
	}
}
