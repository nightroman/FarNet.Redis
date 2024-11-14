
. ./About.ps1

task normal_script {
	Remove-RedisKey ($key = 'test:1')
	$f1 = 'userId'

	$script = "if redis.call('hexists', KEYS[1], ARGV[1]) == 0 then return redis.call('hset', KEYS[1], ARGV[1], ARGV[2]) else return -1 end"

	$r = Invoke-RedisScript $script -Keys $key -Argv $f1, id1
	equals ([int]$r) 1

	$r = Invoke-RedisScript $script -Keys $key -Argv $f1, id2
	equals ([int]$r) (-1)

	$r = Get-RedisHash $key $f1
	equals $r id1

	Remove-RedisKey $key
}

function prepared_script_parameters($key, $a1, $a2) {
	class prepared_script_parameters { [string]$key = $key; [string]$a1 = $a1; [string]$a2 = $a2 }
	[prepared_script_parameters]::new()
}

task prepared_script {
	Remove-RedisKey ($key = 'test:1')
	$f1 = 'userId'

	$script = "if redis.call('hexists', @key, @a1) == 0 then return redis.call('hset', @key, @a1, @a2) else return -1 end"

	$r = Invoke-RedisScript -LuaScript $script -Parameters (prepared_script_parameters $key $f1 id1)
	equals ([int]$r) 1

	$r = Invoke-RedisScript -LuaScript $script -Parameters (prepared_script_parameters $key $f1 id2)
	equals ([int]$r) (-1)

	$r = Get-RedisHash $key $f1
	equals $r id1

	Remove-RedisKey $key
}

task prepared_script_parameters {
	$r = prepared_script_parameters k1 q1 q2
	$type1 = $r.GetType()
	equals $r.key k1

	$r = prepared_script_parameters k2 q3 q4
	$type2 = $r.GetType()
	equals $r.key k2

	equals $type1 $type2
}

task errors {
	$r = Invoke-RedisScript 'redis.call("missing")'
	equals ([string]$r) ''

	$r = Invoke-RedisScript 'return redis.call("missing")'
	equals ([string]$r) 'ERR unknown command'

	try { throw Invoke-RedisScript 'return redis.pcall("missing")' }
	catch { equals "$_" 'ERR [string "return redis.pcall("missing")"]:1: attempt to call a nil value (field ''pcall'')' }
}
