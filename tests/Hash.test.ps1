
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

task bad_Value {
	try { throw Set-RedisHash 1 $null }
	catch { $_; assert ($_ -like '*because it is null.*') }
}

task bad_Delete {
	try { throw Set-RedisHash 1 -Delete $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisHash 1 -Delete @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }
}

task bad_Set {
	try { throw Set-RedisHash 1 -Set $null }
	catch { $_; assert ($_ -like '*because it is null.*') }
}
