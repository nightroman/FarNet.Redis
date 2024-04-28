
. ./About.ps1

task test {
	$key1 = 'test:1'
	$key2 = 'test:2'
	$miss = 'test:missing'
	Set-RedisString -Many @{$key1 = 1; $key2 = 2}

	equals (Test-RedisKey $miss) 0L
	equals (Test-RedisKey $key1) 1L
	equals (Test-RedisKey $key1, $key2) 2L
	equals (Test-RedisKey $key1, $miss) 1L
	equals (Test-RedisKey $miss, $miss) 0L

	Remove-RedisKey $key1, $key2
}

task remove {
	$key1 = 'test:1'
	$key2 = 'test:2'
	$miss = 'test:missing'
	Set-RedisString -Many @{$key1 = 1; $key2 = 2}

	equals (Remove-RedisKey $key1) $null
	equals (Test-RedisKey $key1) 0L

	equals (Remove-RedisKey $key2, $miss -Result) 1L
	equals (Test-RedisKey $key2) 0L
}

task search {
	$list = 1..9
	$list.ForEach{ Set-RedisString "test:\search\key-$_" $_ }

	# simple wildcard
	$keys = Search-RedisKey test:\search\*-? | Sort-Object
	equals $keys.Count 9
	equals $keys[0] test:\search\key-1
	equals $keys[-1] test:\search\key-9

	# glob pattern
	$keys = Search-RedisKey test:\\search\\*-[1-9] | Sort-Object
	equals $keys.Count 9
	equals $keys[0] test:\search\key-1
	equals $keys[-1] test:\search\key-9

	Remove-RedisKey $keys
}

task expiry {
	$key = 'test:1'
	$seconds = 1.0

	Set-RedisString $key 1
	$r = Get-RedisKey $key -TimeToLive
	equals $r $null

	Set-RedisString $key 2 -TimeToLive "00:00:$seconds"
	$r = Get-RedisKey $key -TimeToLive
	equals ([Math]::Round($r.TotalSeconds)) $seconds

	Start-Sleep -Milliseconds 1200
	equals (Test-RedisKey $key) 0L

	Remove-RedisKey $key
}

task TimeToLive {
	Remove-RedisKey ($key = 'test:1')

	Set-RedisString $key 1
	$r = Get-RedisKey $key -TimeToLive
	equals $r $null

	Set-RedisKey $key -TimeToLive 00:00:42
	$r = Get-RedisKey $key -TimeToLive
	equals ([Math]::Round(42 - $r.TotalSeconds)) 0.0

	Set-RedisKey $key -TimeToLive $null
	$r = Get-RedisKey $key -TimeToLive
	equals $r $null

	Remove-RedisKey $key
}
