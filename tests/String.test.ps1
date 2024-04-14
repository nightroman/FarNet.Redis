﻿
. ./About.ps1

task string {
	Remove-RedisKey ($key = 'test:1')

	# set string
	Set-RedisString $key hello

	# test with Get-RedisKey, Get-RedisAny
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::String)
	equals (Get-RedisAny $key) hello

	# get string
	$r = Get-RedisString $key
	equals $r hello

	# get length
	$r = Get-RedisString $key -Length
	equals $r 5L

	Remove-RedisKey $key
}

task set_many {
	Remove-RedisKey ($key1, $key2 = 'test:1', 'test:2')

	Set-RedisString -Many @{$key1 = 1; $key2 = 2}

	$r1, $r2 = Get-RedisString $key1, $key2
	equals $r1 '1'
	equals $r2 '2'

	Remove-RedisKey $key1, $key2
}

task empty_and_null {
	Remove-RedisKey ($key = 'test:1')

	# set empty
	Set-RedisString $key ''
	# is set
	equals (Get-RedisString $key) ''

	# set null
	Set-RedisString $key $null
	# is removed
	equals (Test-RedisKey $key) 0L
	equals (Get-RedisString $key) $null

	Remove-RedisKey $key
}

task set_and_get {
	Remove-RedisKey ($key = 'test:1')

	# set and get missing
	$r = Set-RedisString $key -SetAndGet 1
	equals $r $null

	# set and get existing
	$r = Set-RedisString $key -SetAndGet 2
	equals $r '1'

	# set null and get (null deletes)
	$r = Set-RedisString $key -SetAndGet $null
	equals $r '2'

	# set empty	and get null (empty creates)
	$r = Set-RedisString $key -SetAndGet ''
	equals $r $null

	# final is empty string
	$r = Get-RedisString $key
	equals $r ''

	Remove-RedisKey $key
}

task set_when_one {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisString $key 1 -When Exists
	equals $r $false
	equals (Test-RedisKey $key) 0L

	$r = Set-RedisString $key 1 -When Always
	equals $r $true
	equals (Test-RedisKey $key) 1L

	try { throw Set-RedisString $key 1 -When NotExists }
	catch { assert ('ERR unknown command' -eq $_) }

	Remove-RedisKey $key
}

task set_when_many {
	Remove-RedisKey ($key1, $key2 = 'test:1', 'test:2')

	$r = Set-RedisString -Many @{$key1 = 1; $key2 = 2} -When NotExists
	equals $r $true
	equals (Get-RedisString $key1) '1'
	equals (Get-RedisString $key2) '2'

	$r = Set-RedisString -Many @{$key1 = 3; $key2 = 4} -When Always
	equals $r $true
	equals (Get-RedisString $key1) '3'
	equals (Get-RedisString $key2) '4'

	# works with one
	$r = Set-RedisString -Many @{$key1 = 5} -When Exists
	equals $r $true
	equals (Get-RedisString $key1) '5'

	# but fails with two
	try { throw Set-RedisString -Many @{$key1 = 5; $key2 = 6} -When Exists }
	catch { equals "$_" 'Exists is not valid in this context; the permitted values are: Always, NotExists' }

	# both exist -> false, nothing is set
	$r = Set-RedisString -Many @{$key1 = 1; $key2 = 2} -When NotExists
	equals $r $false
	equals (Get-RedisString $key1) '5'
	equals (Get-RedisString $key2) '4'

	# some missing -> true, something is set
	Remove-RedisKey $key1
	$r = Set-RedisString -Many @{$key1 = 1; $key2 = 2} -When NotExists
	equals $r $true
	equals (Get-RedisString $key1) '1'
	equals (Get-RedisString $key2) '4' #! note the old value

	Remove-RedisKey $key1, $key2
}

task append {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisString $key -Append a
	equals $r 1L

	$r = Set-RedisString $key -Append b
	equals $r 2L

	$r = Get-RedisString $key
	equals $r ab

	Remove-RedisKey $key
}

task increment {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisString $key -Increment 2
	equals $r 2L

	$r = Set-RedisString $key -Increment (-1)
	equals $r 1L

	$r = Set-RedisString $key -Decrement 2
	equals $r (-1L)

	$r = Set-RedisString $key -Decrement (-1)
	equals $r 0L

	Remove-RedisKey $key
}
