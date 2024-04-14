
. ./About.ps1

task set {
	Remove-RedisKey ($key = 'test:1')

	# set new set not yet existed
	Set-RedisSet $key Joe, 42

	# test with Get-RedisKey, Get-RedisAny
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::Set)
	$r = Get-RedisAny $key
	equals $r.Count 2
	assert $r.Contains('Joe')
	assert $r.Contains('42')

	# set new set over existing
	Set-RedisSet $key May, 11
	$r = Get-RedisSet $key
	equals $r.Count 2
	assert $r.Contains('May')
	assert $r.Contains('11')

	# add one new
	Set-RedisSet $key -Add Joe
	$r = Get-RedisSet $key
	equals $r.Count 3
	assert $r.Contains('Joe')

	# add two, one exists
	Set-RedisSet $key -Add 42, Joe
	$r = Get-RedisSet $key
	equals $r.Count 4
	assert $r.Contains('42')

	equals (Get-RedisSet $key -Count) 4L

	# remove one
	Set-RedisSet $key -Remove 11
	equals (Get-RedisSet $key -Count) 3L

	# remove two, one missing
	Set-RedisSet $key -Remove 42, miss
	equals (Get-RedisSet $key -Count) 2L

	Remove-RedisKey $key
}

#! fixed
task empty_strings {
	$key = 'test:1'

	Set-RedisSet $key '', 1
	$r = (Get-RedisSet $key) -join '|'
	equals $r '|1'

	Set-RedisSet $key ''
	$r = Get-RedisSet $key
	equals $r.Count 1
	equals @($r)[0] ''

	Remove-RedisKey $key
}

task bad_Value {
	try { throw Set-RedisSet 1 $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisSet 1 @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }
}

task bad_Add {
	try { throw Set-RedisSet 1 -Add $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisSet 1 -Add @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }
}
