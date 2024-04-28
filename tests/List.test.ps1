
. ./About.ps1

task list {
	Remove-RedisKey ($key = 'test:1')

	# set new list not yet existed
	Set-RedisList $key @('Joe'; 42)

	# test with Get-RedisKey, Get-RedisAny
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::List)
	$r = Get-RedisAny $key
	equals $r.Count 2
	equals $r[0] Joe
	equals $r[1] '42'

	# test Count and Index
	equals (Get-RedisList $key -Count) 2L
	equals (Get-RedisList $key -Index 0) Joe
	equals (Get-RedisList $key -Index -1) '42'
	equals (Get-RedisList $key -Index 42) $null

	Set-RedisList $key -LeftPush left
	$r = Get-RedisList $key
	equals $r.Count 3
	equals $r[0] left

	Set-RedisList $key -RightPush right
	$r = Get-RedisList $key
	equals $r.Count 4
	equals $r[-1] right

	$r = Get-RedisList $key -Count
	equals $r 4L

	Remove-RedisKey $key
}

task list_pop {
	$key = 'test:1'
	Set-RedisList $key (1..9)

	equals (Set-RedisList $key -LeftPop 1) '1'
	equals (Set-RedisList $key -RightPop 1) '9'

	$r1, $r2 = Set-RedisList $key -LeftPop 2
	equals $r1 '2'
	equals $r2 '3'

	$r1, $r2 = Set-RedisList $key -RightPop 2
	equals $r1 '8'
	equals $r2 '7'

	equals (Get-RedisList $key -Count) 3L

	Remove-RedisKey $key
}

task result_is_List {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisList $key 1

	$r = Get-RedisList $key
	assert $r.Count 1
	equals $r[0] '1'
	equals $r.GetType() ([System.Collections.Generic.List[string]])

	Remove-RedisKey $key
}

#! fixed
task empty_strings {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisList $key '', 1
	$r = (Get-RedisList $key) -join '|'
	equals $r '|1'

	Set-RedisList $key ''
	$r = (Get-RedisList $key) -join '|'
	equals $r '|1|'

	Remove-RedisKey $key
}

# Use (,) notation in order to pass byte[] values avoiding unrolling to object[].
task bytes {
	Remove-RedisKey ($key = 'test:1')

	[byte[]]$b1 = @(201; 1)
	Set-RedisList $key (,$b1)

	[byte[]]$b2 = @(202)
	[byte[]]$b3 = @(203)
	Set-RedisList $key -LeftPush @((,$b2); (,$b3))

	[byte[]]$b4 = @(204)
	[byte[]]$b5 = @(205)
	Set-RedisList $key -RightPush @((,$b4); (,$b5))

	$r = $db.ListRange($key).ForEach{([byte[]]$_)[0]} -join ','
	equals $r '203,202,201,204,205'

	Remove-RedisKey $key
}

task invalid {
	# Value

	try { throw Set-RedisList 1 $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisList 1 @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	try { throw Set-RedisList 1 $Host }
	catch { $_; assert ($_ -like "*'RedisValue':*") }

	# LeftPush

	try { throw Set-RedisList 1 -LeftPush $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisList 1 -LeftPush @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	try { throw Set-RedisList 1 -LeftPush $Host }
	catch { $_; assert ($_ -like "*'RedisValue':*") }

	# RightPush

	try { throw Set-RedisList 1 -RightPush $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisList 1 -RightPush @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	try { throw Set-RedisList 1 -RightPush $Host }
	catch { $_; assert ($_ -like "*'RedisValue':*") }
}
