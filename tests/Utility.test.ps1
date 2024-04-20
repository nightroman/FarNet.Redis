
. ./About.ps1

task open_redis {
	# should be the same instance
	$db2 = Open-Redis 127.0.0.1:3278
	equals ([object]::ReferenceEquals($db2, $db)) $true

	# should be a different instance, close it
	$db2 = Open-Redis 127.0.0.1:3278 -AllowAdmin
	equals ([object]::ReferenceEquals($db2, $db)) $false
	Close-Redis -Database $db2
}

<#
	Set-RedisClixml and Get-RedisClixml provide low ceremony persistence of PowerShell objects.
	See the similar Export-Clixml and Import-Clixml for concepts and examples.

	NOTE:
	ConvertTo-Json and ConvertFrom-Json provide better performance.
	But the supported data types are not that rich as with CLIXML.
#>
task clixml_flat {
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

<#
	Depth 1 does not mean excluded nested objects.
	For example this test preserves 3 levels.
#>
task clixml_deep {
	$key = 'test:1'

	$data = @{
		t1 = @{
			t2 = @{
				t3 = @{
					Version = $Host.Version
				}
			}
		}
		o1 = [pscustomobject]@{
			o2 = [pscustomobject]@{
				o3 = [pscustomobject] @{
					Version = $Host.Version
				}
			}
		}
	}

	Set-RedisClixml $key $data -Depth 1

	$r = Get-RedisClixml $key
	equals $r.t1.t2.t3.Version $Host.Version
	equals $r.o1.o2.o3.Version $Host.Version
	assert ($r.t1 -is [hashtable])
	assert ($r.o1 -is [pscustomobject])

	Remove-RedisKey $key
}
