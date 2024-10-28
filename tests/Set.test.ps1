
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

	# add one new
	Set-RedisSet $key May
	$r = Get-RedisSet $key
	equals $r.Count 3
	assert $r.Contains('May')

	# add two, one exists
	Set-RedisSet $key -Add 11, Joe
	$r = Get-RedisSet $key
	equals $r.Count 4
	assert $r.Contains('11')

	equals (Get-RedisSet $key -Count) 4L

	# remove one
	Set-RedisSet $key -Remove 11
	equals (Get-RedisSet $key -Count) 3L

	# remove two, one missing
	Set-RedisSet $key -Remove 42, miss
	equals (Get-RedisSet $key -Count) 2L

	Remove-RedisKey $key
}

task pattern {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisSet $key apple, banana, orange

	$r = Get-RedisSet $key -Pattern $null
	equals $r.Count 3

	$r = Get-RedisSet $key -Pattern ''
	equals $r.Count 3

	$r = Get-RedisSet $key -Pattern *n*
	equals $r.Count 2

	$r = Get-RedisSet $key -Pattern a*
	equals $r apple

	$r = Get-RedisSet $key -Pattern z*
	equals $r $null

	Remove-RedisKey $key
}

# Use (,) notation in order to pass byte[] values avoiding unrolling to object[].
task bytes {
	$key = 'test:1'

	[byte[]]$b1 = @(201, 1)
	Set-RedisSet $key (,$b1)

	[byte[]]$b2 = @(202, 2)
	[byte[]]$b3 = @(203, 3)
	Set-RedisSet $key -Add @((,$b2); (,$b3))

	Set-RedisSet $key -Remove (,$b1)

	$r = $db.SetMembers($key)

	$r0 = $r.ForEach{([byte[]]$_)[0]} -join ','
	equals $r0 '202,203'

	$r1 = $r.ForEach{([byte[]]$_)[1]} -join ','
	equals $r1 '2,3'

	Remove-RedisKey $key
}

task result_types {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisSet $key v1
	$r = Get-RedisSet $key
	assert $r.GetType() ([string])
	equals $r v1

	Set-RedisSet $key v2
	$r = Get-RedisSet $key
	assert $r.GetType() ([object[]])
	equals $r[0] v1
	equals $r[1] v2

	Remove-RedisKey $key
}

task empty_strings {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisSet $key '', 1
	$r = (Get-RedisSet $key) -join '|'
	equals $r '|1'

	Set-RedisSet $key -Remove ''
	$r = (Get-RedisSet $key) -join '|'
	equals $r '1'

	Set-RedisSet $key ''
	$r = (Get-RedisSet $key) -join '|'
	equals $r '|1'

	Remove-RedisKey $key
}

task invalid {
	# Add omitted

	try { throw Set-RedisSet 1 $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisSet 1 @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	try { throw Set-RedisSet 1 $Host }
	catch { $_; assert ($_ -like "*'RedisValue':*") }

	# Add explicit

	try { throw Set-RedisSet 1 -Add $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisSet 1 -Add @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	try { throw Set-RedisSet 1 -Add $Host }
	catch { $_; assert ($_ -like "*'RedisValue':*") }

	# Remove

	try { throw Set-RedisSet 1 -Remove $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisSet 1 -Remove @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	try { throw Set-RedisSet 1 -Remove $Host }
	catch { $_; assert ($_ -like "*'RedisValue':*") }
}
