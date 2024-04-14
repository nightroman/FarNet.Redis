
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

	# set new list over existing
	Set-RedisList $key @('May'; 11)
	$r = Get-RedisList $key
	equals $r.Count 2
	equals $r[0] May
	equals $r[1] '11'

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

task result_List {
	$key = 'test:1'
	Remove-RedisKey $key
	assert (!(Test-RedisKey $key))

	# key does not exist -> empty list, useful for adding items
	$r = Get-RedisList $key
	assert (!$r)
	equals $r.GetType() ([System.Collections.Generic.List[string]])

	# add one item, set
	$r.Add(1)
	Set-RedisList $key $r
	assert (Test-RedisKey $key)

	$r = Get-RedisList $key
	assert $r.Count 1
	equals $r[0] '1'
	equals $r.GetType() ([System.Collections.Generic.List[string]])

	# add another item, set
	$r.Add(2)
	Set-RedisList $key $r

	$r = Get-RedisList $key
	assert $r.Count 2
	equals $r[1] '2'
	equals $r.GetType() ([System.Collections.Generic.List[string]])

	Remove-RedisKey $key
}

#! fixed
task empty_strings {
	$key = 'test:1'

	Set-RedisList $key '', 1
	$r = (Get-RedisList $key) -join '|'
	equals $r '|1'

	Set-RedisList $key ''
	$r = Get-RedisList $key
	equals $r.Count 1
	equals $r[0] ''

	Remove-RedisKey $key
}

task bad_Value {
	try { throw Set-RedisList 1 $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisList 1 @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }
}

task bad_LeftPush {
	try { throw Set-RedisList 1 -LeftPush $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisList 1 -LeftPush @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }
}

task bad_RightPush {
	try { throw Set-RedisList 1 -RightPush $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisList 1 -RightPush @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }
}
