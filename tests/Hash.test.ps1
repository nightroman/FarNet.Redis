
. ./About.ps1

task hash {
	$key = 'test:hash1'

	Set-RedisHash $key @{name = 'Joe'; age = 42}
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::Hash)

	$r = Get-RedisAny $key
	equals $r.Count 2
	equals $r.name Joe
	equals $r.age '42'

	Set-RedisHash $key @{user = 'May'; id = 11}
	$r = Get-RedisHash $key
	equals $r.Count 2
	equals $r.user May
	equals $r.id '11'

	Set-RedisHash $key -Update @{name = 'Joe'; age = 42}
	$r = Get-RedisHash $key
	equals $r.Count 4
	equals $r.name Joe
	equals $r.age '42'
	equals $r.user May
	equals $r.id '11'

	$r = Get-RedisHash $key -Count
	equals $r 4L

	Remove-RedisKey $key
}
