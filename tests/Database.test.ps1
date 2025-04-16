
. ./About.ps1

task defaultDatabase {
	$db1 = Open-Redis '127.0.0.1:3278,defaultDatabase=1'
	equals 1 $db1.Database
}

task db_and_db1 {
	$key = 'test:q1'

	$db1 = Open-Redis $db.Multiplexer.Configuration -Index 1

	Remove-RedisKey $key
	Remove-RedisKey $key -Database $db1

	Set-RedisString $key q1 -Database $db1

	equals $null (Get-RedisString $key)
	equals q1 (Get-RedisString $key -Database $db1)

	equals $null (Search-RedisKey $key)
	equals $key (Search-RedisKey $key -Database $db1)

	Remove-RedisKey $key -Database $db1
}
