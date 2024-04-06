
. ./About.ps1

task string {
	$key = 'test:string1'
	$value = 'test:string1-value'

	Set-RedisString $key $value
	equals (Get-RedisKey $Key) ([StackExchange.Redis.RedisType]::String)

	$r = Get-RedisAny $key
	equals $r $value

	$r = Get-RedisString $key
	equals $r $value

	$r = Get-RedisString $key -Length
	equals $r 18L

	Remove-RedisKey $key
}

task strings {
	$key1 = 'test:string1'
	$key2 = 'test:string2'
	$value1 = 'test:string1-value'
	$value2 = 'test:string2-value'

	Set-RedisString $key1, $key2 $value1, $value2

	$r1, $r2 = Get-RedisString $key1, $key2
	equals $r1 $value1
	equals $r2 $value2

	Remove-RedisKey $key1, $key2
}

task null {
	$key = 'test:string1'

	Set-RedisString $key ''
	$r = Get-RedisString $key
	equals $r ''

	# setting $null removes the key
	Set-RedisString $key $null
	$r = Test-RedisKey 0
	$r = Get-RedisString $key
	equals $r $null
}

task set_get {
	$key = 'test:get1'
	Remove-RedisKey $key

	$r = Set-RedisString $key 1 -Get
	equals $r $null

	$r = Set-RedisString $key 2 -Get
	equals $r '1'

	Remove-RedisKey $key
}

task set_when {
	$key = 'test:get1'
	Remove-RedisKey $key

	$r = Set-RedisString $key 1 -When Exists
	equals $r $false
	equals (Test-RedisKey $key) 0L

	$r = Set-RedisString $key 1 -When Always
	equals $r $true
	equals (Test-RedisKey $key) 1L

	Remove-RedisKey $key
}

task append {
	$key = 'test:1'
	Remove-RedisKey $key

	$r = Set-RedisString $key -Append 'a-'
	equals $r 2L

	$r = Set-RedisString $key -Append 'b-'
	equals $r 4L

	$r = Get-RedisString $key
	equals $r a-b-

	Remove-RedisKey $key
}

task increment {
	$key = 'test:1'
	Remove-RedisKey $key

	$r = Set-RedisString $key -Increment 2
	equals $r 2.0

	$r = Set-RedisString $key -Decrement 3
	equals $r (-1.0)

	Remove-RedisKey $key
}
