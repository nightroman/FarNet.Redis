
. ./About.ps1

task hash {
	Remove-RedisKey ($key = 'test:1')

	# set two fields
	Set-RedisHash $key @{name = 'Joe'; age = 42}

	# test with Get-RedisKey, Get-RedisAny
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::Hash)
	$r = Get-RedisAny $key
	equals $r.GetType() ([hashtable])
	equals $r.Count 2
	equals $r.name Joe
	equals $r.age '42'

	# get hashtable
	$r = Get-RedisHash $key
	equals $r.GetType() ([hashtable])
	equals $r.Count 2
	equals $r.name Joe
	equals $r.age '42'

	# get one field
	$r = Get-RedisHash $key name
	equals $r Joe

	# get two fields
	$name, $age = Get-RedisHash $key name, age
	equals $name Joe
	equals $age '42'

	# set extra field
	Set-RedisHash $key id 11
	$r = Get-RedisHash $key
	equals $r.Count 3
	equals $r.id '11'

	# set entries in existing hash
	Set-RedisHash $key @{name = 'May'; age = 33}
	$r = Get-RedisHash $key
	equals $r.Count 3
	equals $r.name May
	equals $r.age '33'
	equals $r.id '11'

	# get 1 field
	$r = Get-RedisHash $key miss
	equals $r $null

	# get 3 fields
	$name, $miss, $age = Get-RedisHash $key name, miss, age
	equals $name May
	equals $miss $null
	equals $age '33'

	# remove 1 field
	Set-RedisHash $key -Remove id
	equals (Get-RedisHash $key -Count) 2L

	# remove 2 fields, one missing
	Set-RedisHash $key -Remove miss, age
	equals (Get-RedisHash $key -Count) 1L

	# test
	$r = Get-RedisHash $key
	equals $r.Count 1
	equals $r.name May

	Remove-RedisKey $key
}

task pattern {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisHash $key @{apple = 1; banana = 2; orange = 3}

	$r = Get-RedisHash $key -Pattern $null
	equals $r.Count 3

	$r = Get-RedisHash $key -Pattern ''
	equals $r.Count 3

	$r = Get-RedisHash $key -Pattern *n*
	equals $r.Count 2

	$r = Get-RedisHash $key -Pattern a*
	equals $r.Count 1

	$r = Get-RedisHash $key -Pattern z*
	equals $r.Count 0

	Remove-RedisKey $key
}

#! `-When Exists` errors, not supported
task when {
	Remove-RedisKey ($key = 'test:1')

	# Always

	# true: new field set
	$r = Set-RedisHash $key k1 v1 -When Always
	equals $r $true
	equals (Get-RedisHash $key k1) v1

	# false: old field, updated
	$r = Set-RedisHash $key k1 v2 -When Always
	equals $r $false
	equals (Get-RedisHash $key k1) v2

	# NotExists

	# true: new field set
	$r = Set-RedisHash $key k2 v1 -When NotExists
	equals $r $true
	equals (Get-RedisHash $key k2) v1

	# false: old field, not changed
	$r = Set-RedisHash $key k2 v2 -When NotExists
	equals $r $false
	equals (Get-RedisHash $key k2) v1

	# two result fields
	$r = Get-RedisHash $key -Count
	equals $r 2L

	Remove-RedisKey $key
}

# In order to use byte[] values, ensure the type is byte[].
task bytes {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisHash $key @{k1 = [byte[]](201)}

	$r = [byte[]]$db.HashGet($key, 'k1')
	equals $r[0] 201uy

	Set-RedisHash $key @{k2 = [byte[]](0, 202)}

	$r = [byte[]]$db.HashGet($key, 'k1')
	equals $r[0] 201uy

	$r = [byte[]]$db.HashGet($key, 'k2')
	equals $r[1] 202uy

	Remove-RedisKey $key
}

task increment_decrement {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisHash $key k1 -Increment 2
	equals $r 2L

	$r = Set-RedisHash $key k1 -Increment (-1)
	equals $r 1L

	$r = Set-RedisHash $key k1 -Decrement 2
	equals $r (-1L)

	$r = Set-RedisHash $key k1 -Decrement (-1)
	equals $r 0L

	Remove-RedisKey $key
}

task add_subtract {
	Remove-RedisKey ($key = 'test:1')

	$r = Set-RedisHash $key k1 -Add 2.1
	equals $r 2.1

	$r = Set-RedisHash $key k1 -Add (-1.2)
	assert ([Math]::Abs($r - 0.9) -lt 1e-15)

	$r = Set-RedisHash $key k1 -Subtract 2.3
	assert ([Math]::Abs($r - (-1.4)) -lt 1e-15)

	$r = Set-RedisHash $key k1 -Subtract (-1.4)
	assert ([Math]::Abs($r) -lt 1e-15)

	Remove-RedisKey $key
}

task valid {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisHash $key empty1 ''
	equals (Get-RedisHash $key empty1) ''

	Set-RedisHash $key empty2 ''
	equals (Get-RedisHash $key empty2) ''

	equals (Get-RedisHash $key -Count) 2L

	Remove-RedisKey $key
}

task invalid {
	# Get Field

	try { throw Get-RedisHash key $null }
	catch { $_; assert ($_ -like "*'Field'. The argument is null or empty.*") }

	try { throw Get-RedisHash key -Field $null }
	catch { $_; assert ($_ -like "*'Field'. The argument is null or empty.*") }

	try { throw Get-RedisHash key @() }
	catch { $_; assert ($_ -like "*'Field'. The argument is null, empty, or *") }

	try { throw Get-RedisHash key -Field @() }
	catch { $_; assert ($_ -like "*'Field'. The argument is null, empty, or *") }

	# Set Field

	try { throw Set-RedisHash key $null value }
	catch { $_; assert ($_ -like "Cannot * 'Many'*") } #! odd 'Many'

	try { throw Set-RedisHash key -Field $null value }
	catch { $_; assert ($_ -like "Cannot * 'Field'*") }

	try { throw Set-RedisHash key -Field @() value }
	catch { $_; assert ($_ -like "Cannot * 'Field'*") }

	try { throw Set-RedisHash key -Field $host value }
	catch { $_; assert ($_ -like "Cannot * 'Field'*") }

	try { throw Set-RedisHash key -Field @($host) value }
	catch { $_; assert ($_ -like "Cannot * 'Field'*") }

	# Set Value

	try { throw Set-RedisHash key field $null }
	catch { $_; assert ($_ -like "*'Value' because it is null.*") }

	try { throw Set-RedisHash key field -Value $null }
	catch { $_; assert ($_ -like "*'Value' because it is null.*") }

	# Set Remove

	try { throw Set-RedisHash key -Remove $null }
	catch { $_; assert ($_ -like '*because it is null.*') }

	try { throw Set-RedisHash key -Remove @() }
	catch { $_; assert ($_ -like '*because it is an empty array.*') }

	# Set Many

	try { throw Set-RedisHash key @{k=$Host} }
	catch { $_; assert ($_ -like "*'Many'*'RedisValue':*") }

	try { throw Set-RedisHash key -Many $null }
	catch { $_; assert ($_ -like "*'Many' because it is null.*") }

	try { throw Set-RedisHash key -Many @{k=$Host} }
	catch { $_; assert ($_ -like "*'Many'*'RedisValue':*") }
}
