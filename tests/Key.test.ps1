
. ./About.ps1

task test {
	$key1 = 'test:key1'
	$key2 = 'test:key2'
	$miss = 'test:missing'
	Set-RedisString $key1, $key2 1, 2

	equals (Test-RedisKey $miss) 0L
	equals (Test-RedisKey $key1) 1L
	equals (Test-RedisKey $key1, $key2) 2L
	equals (Test-RedisKey $key1, $miss) 1L
	equals (Test-RedisKey $miss, $miss) 0L

	Remove-RedisKey $key1, $key2
}

task remove {
	$key1 = 'test:key1'
	$key2 = 'test:key2'
	$miss = 'test:missing'
	Set-RedisString $key1, $key2 1, 2

	equals (Remove-RedisKey $key1) $null
	equals (Test-RedisKey $key1) 0L

	equals (Remove-RedisKey $key2, $miss -Result) 1L
	equals (Test-RedisKey $key2) 0L
}

task search {
	$list = 1..9
	$list.ForEach{ Set-RedisString "test:search:$_" $_ }

	$keys = Search-RedisKey test:search:* | Sort-Object
	equals $keys.Count 9
	equals $keys[0] test:search:1
	equals $keys[-1] test:search:9

	Remove-RedisKey $keys
}

task expiry {
	$key = 'test:key1'
	$seconds = 1.0

	Set-RedisString $key 1
	$r = Get-RedisKey $key -TimeToLive
	equals $r $null

	Set-RedisString $key 2 -Expiry (New-TimeSpan -Seconds $seconds)
	$r = Get-RedisKey $key -TimeToLive
	equals ([Math]::Round($r.TotalSeconds)) $seconds

	Start-Sleep -Milliseconds 1200
	equals (Test-RedisKey $key) 0L

	Remove-RedisKey $key
}
