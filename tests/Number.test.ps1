
. ./About.ps1

# Note floating point noise. `Set-RedisString` works the same with numbers.
task number {
	Remove-RedisKey ($key = 'test:1')

	# set number
	Set-RedisNumber $key 3.14

	# test with Get-RedisKey, Get-RedisAny
	equals (Get-RedisKey $key) ([StackExchange.Redis.RedisType]::String)
	equals (Get-RedisAny $key) '3.1400000000000001'

	# get string
	$r = Get-RedisString $key
	equals $r '3.1400000000000001'

	Remove-RedisKey $key
}

# (similar to String test)
task set_when {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisNumber $key 1 -When Exists
	equals $r $false
	equals (Test-RedisKey $key) 0L

	$r = Set-RedisNumber $key 1 -When Always
	equals $r $true
	equals (Get-RedisString $key) '1'

	# Garnet v1.0.34, was "unknown command"
	$r = Set-RedisNumber $key 2 -When NotExists
	equals $r $false
	Remove-RedisKey $key
	$r = Set-RedisNumber $key 2 -When NotExists
	equals $r $true
	equals (Get-RedisString $key) '2'

	Remove-RedisKey $key
}

task increment_decrement {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisNumber $key -Increment 2
	equals $r 2L

	$r = Set-RedisNumber $key -Increment (-1)
	equals $r 1L

	$r = Set-RedisNumber $key -Decrement 2
	equals $r (-1L)

	$r = Set-RedisNumber $key -Decrement (-1)
	equals $r 0L

	Remove-RedisKey $key
}

task add_subtract {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisNumber $key -Add 2.1
	equals $r 2.1

	$r = Set-RedisNumber $key -Add (-1.2)
	equals $r 0.9

	$r = Set-RedisNumber $key -Subtract 2.3
	equals $r (-1.4)

	$r = Set-RedisNumber $key -Subtract (-1.4)
	equals $r 0.0

	Remove-RedisKey $key
}

task bad_number {
	Remove-RedisKey ($key = 'test:1')

	# not integer
	Set-RedisNumber $key 1.1

	try { throw Set-RedisNumber $key -Increment 1 }
	catch { equals "$_" 'ERR value is not an integer or out of range.' }

	try { throw Set-RedisNumber $key -Decrement 1 }
	catch { equals "$_" 'ERR value is not an integer or out of range.' }

	# not number
	Set-RedisString $key bar

	try { throw Set-RedisNumber $key -Increment 1 }
	catch { equals "$_" 'ERR value is not an integer or out of range.' }

	try { throw Set-RedisNumber $key -Decrement 1 }
	catch { equals "$_" 'ERR value is not an integer or out of range.' }

	try { throw Set-RedisNumber $key -Add 1 }
	catch { equals "$_" 'ERR value is not a valid float' }

	try { throw Set-RedisNumber $key -Subtract 1 }
	catch { equals "$_" 'ERR value is not a valid float' }
}

task auto_update_expiring {
	function GetOrAdd($value) {
		(Get-RedisString $key) ?? (&{
			Set-RedisNumber $key $value -TimeToLive 00:00:00.05
			$value
		})
	}

	Remove-RedisKey ($key = 'test:1')

	# try and suggest 1 -> new 1
	$r = GetOrAdd 1
	equals $r 1

	# try and suggest 2 -> old 1
	$r = GetOrAdd 2
	equals $r '1'

	# let it expire
	Start-Sleep -Milliseconds 50

	# try and suggest 3 -> new 3
	$r = GetOrAdd 3
	equals $r 3
	equals (Get-RedisString $key) '3'

	Remove-RedisKey $key
}

task invalid {
	try { throw Set-RedisNumber 1 $null }
	catch { $_; assert ($_ -like "*Cannot bind argument to parameter 'Value' because it is null.*") }

	try { throw Set-RedisNumber 1 @() }
	catch { $_; assert ($_ -like "*Cannot convert 'System.Object*' to the type 'System.Double'*") }
}
