
. ./About.ps1

task one_handler {
	Remove-RedisKey ($key = 'test:1')

	# register
	$handler = Register-RedisSub test {
		param($channel, $message)
		Set-RedisString $key $message
	}

	# send message
	$r = $db.Publish('test', 'hello')
	equals $r 1L

	# wait, test
	$r = Wait-RedisString $key ([timespan]::FromMilliseconds(50)) ([timespan]::FromMilliseconds(5000))
	equals $r hello

	# unregister
	Unregister-RedisSub test $handler

	Remove-RedisKey $key
}

task many_handlers {
	$log = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()

	# register 3 handlers
	$handler1 = Register-RedisSub test {
		param($channel, $message)
		$log.Enqueue("1 $message")
	}
	$handler2 = Register-RedisSub test {
		param($channel, $message)
		$log.Enqueue("2 $message")
	}
	$handler3 = Register-RedisSub test {
		param($channel, $message)
		$log.Enqueue("3 $message")
	}

	# send to 3 handlers
	$r = $db.Publish('test', 'message1')
	$log.Enqueue("publish 1")
	Start-Sleep 1

	# remove handler 1
	Unregister-RedisSub test $handler1

	# send to 2 handlers
	$r = $db.Publish('test', 'message2')
	$log.Enqueue("publish 2")
	Start-Sleep 1

	# remove handlers
	Unregister-RedisSub test

	# send to none
	$r = $db.Publish('test', 'message3')
	$log.Enqueue("publish 3")
	Start-Sleep 1

	# expected log
	($r = @($log))
	equals $r.Count 8
	equals $r[0] 'publish 1'
	equals $r[1] '1 message1'
	equals $r[2] '2 message1'
	equals $r[3] '3 message1'
	equals $r[4] 'publish 2'
	equals $r[5] '2 message2'
	equals $r[6] '3 message2'
	equals $r[7] 'publish 3'
}
