
. ./About.ps1

task 2024-04-02-1313 {
	$key = 'test:2024-04-02-1313'

	# `StringSet` fails with `NotExists`
	try {
		throw $db.StringSet($key, '1', $null, $false, [StackExchange.Redis.When]::NotExists, [StackExchange.Redis.CommandFlags]::None)
	}
	catch {
		assert "$_".EndsWith('"ERR unknown command"')
	}

	$server = Get-RedisServer
	equals $server.Features.SetAndGet $true
	equals $server.Features.SetNotExistsAndGet $false
}
