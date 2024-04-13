
. ./About.ps1

<#
	Set-RedisClixml and Get-RedisClixml provide low ceremony persistence of PowerShell objects.
	See the similar Export-Clixml and Import-Clixml for concepts and examples.

	NOTE:
	ConvertTo-Json and ConvertFrom-Json provide better performance.
	But the supported data types are not that rich as with CLIXML.
#>
task clixml {
	$key = 'test:1'

	$data = @{
		Null = $null
		True = $true
		Int = 42
		Long = 42L
		Double = 3.14
		String = 'hello'
		DateTime = [datetime]'2024-04-13'
		TimeSpan = [timespan]::FromSeconds(42)
		Guid = [guid]'3a06ad4e-0721-4d76-814f-2220d11a689f'
		Version = [version]'1.2.3'
	}

	Set-RedisClixml $key $data
	$r = Get-RedisClixml $key

	equals $r.Null $null
	equals $r.True $true
	equals $r.Int 42
	equals $r.Long 42L
	equals $r.Double 3.14
	equals $r.String hello
	equals $r.DateTime $data.DateTime
	equals $r.TimeSpan $data.TimeSpan
	equals $r.Guid $data.Guid
	equals $r.Version $data.Version

	Remove-RedisKey $key
}
