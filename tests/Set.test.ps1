
. ./About.ps1

task set {
	$key = 'test:set1'

	Set-RedisSet $key Joe, 42
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::Set)

	$r = Get-RedisAny $key
	equals $r.Count 2
	assert $r.Contains('Joe')
	assert $r.Contains('42')

	Set-RedisSet $key May, 11
	$r = Get-RedisSet $key
	equals $r.Count 2
	assert $r.Contains('May')
	assert $r.Contains('11')

	Set-RedisSet $key -Add Joe
	$r = Get-RedisSet $key
	equals $r.Count 3
	assert $r.Contains('Joe')

	Set-RedisSet $key -Add 42
	$r = Get-RedisSet $key
	equals $r.Count 4
	assert $r.Contains('42')

	$r = Get-RedisSet $key -Count
	equals $r 4L

	Remove-RedisKey $key
}
