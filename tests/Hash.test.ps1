
. ./About.ps1

task hash {
	Remove-RedisKey ($key = 'test:1')

	# set new hash not yet existed
	Set-RedisHash $key @{name = 'Joe'; age = 42}

	# test with Get-RedisKey, Get-RedisAny
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::Hash)
	$r = Get-RedisAny $key
	equals $r.Count 2
	equals $r.name Joe
	equals $r.age '42'

	# set new hash over existing
	Set-RedisHash $key @{user = 'May'; id = 11}
	$r = Get-RedisHash $key
	equals $r.Count 2
	equals $r.user May
	equals $r.id '11'

	# set entries in existing hash
	Set-RedisHash $key -Set @{name = 'Joe'; age = 42}
	$r = Get-RedisHash $key
	equals $r.Count 4
	equals $r.name Joe
	equals $r.age '42'
	equals $r.user May
	equals $r.id '11'

	# get 1 field
	$r = Get-RedisHash $key -Field name
	equals $r Joe
	$r = Get-RedisHash $key -Field miss
	equals $r $null

	# get 3 fields
	$name, $miss, $age = Get-RedisHash $key -Field name, miss, age
	equals $name Joe
	equals $miss $null
	equals $age '42'

	# delete 1 field
	Set-RedisHash $key -Delete id
	equals (Get-RedisHash $key -Count) 3L

	# delete 2 fields
	Set-RedisHash $key -Delete user, age
	equals (Get-RedisHash $key -Count) 1L

	# test
	$r = Get-RedisHash $key
	equals $r.Count 1
	equals $r.name Joe

	Remove-RedisKey $key
}

# In order to use byte[] values, ensure the type is byte[].
task bytes {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisHash $key @{k1 = [byte[]](201)}

	$r = [byte[]]$db.HashGet($key, 'k1')
	equals $r[0] 201uy

	Set-RedisHash $key -Set @{k2 = [byte[]](0, 202)}

	$r = [byte[]]$db.HashGet($key, 'k1')
	equals $r[0] 201uy

	$r = [byte[]]$db.HashGet($key, 'k2')
	equals $r[1] 202uy

	Remove-RedisKey $key
}

task invalid {
	# Field

	try { throw Get-RedisHash 1 -Field $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Get-RedisHash 1 -Field @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	# Value

	try { throw Set-RedisHash 1 $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisHash 1 @{k=$Host} }
	catch { $_; assert ($_ -like "*'RedisValue':*") }

	# Delete

	try { throw Set-RedisHash 1 -Delete $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisHash 1 -Delete @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	# Set

	try { throw Set-RedisHash 1 -Set $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisHash 1 -Set @{k=$Host} }
	catch { $_; assert ($_ -like "*'RedisValue':*") }
}
