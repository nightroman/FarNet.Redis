
. ./About.ps1

task list {
	$key = 'test:1'

	Set-RedisList $key @('Joe'; 42)
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::List)

	$r = Get-RedisAny $key
	equals $r.Count 2
	equals $r[0] Joe
	equals $r[1] '42'

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

task result_List {
	$key = 'test:1'
	Remove-RedisKey $key
	assert (!(Test-RedisKey $key))

	# key does not exist -> empty list, useful for adding items
	$r = Get-RedisList $key
	assert (!$r)
	equals $r.GetType() ([System.Collections.Generic.List[string]])

	# set empty list does not create
	Set-RedisList $key $r
	assert (!(Test-RedisKey $key))

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

	# set empty list deletes the key
	Set-RedisList $key @()
	assert (!(Test-RedisKey $key))
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
