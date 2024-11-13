
. ./About.ps1

<#
	Using Use-RedisLock, typical scenario.
#>
task using_cmdlet {
	Remove-RedisKey ($key = 'test:lock1')

	# 1 sec delay, 1 min timeout
	Use-RedisLock $key {
		# lock taken, do work
	}

	equals (Test-RedisKey $key) 0L
}

<#
	Using SERedis LockTake and LockRelease.
	https://stackoverflow.com/a/25138164/323582
#>
task using_SERedis {
	$key = 'test:lock1'
	$token = [guid]::NewGuid().ToString()

	if ($db.LockTake($key, $token, '0:1')) {
		try {
			equals $token (Get-RedisString $key)
		}
		finally {
			$null = $db.LockRelease($key, $token)
		}
	}

	equals (Test-RedisKey $key) 0L
}

<#
	This is a safe way of updating shared resource data.
	Some sort of lock is needed, e.g. Use-RedisLock.
	Compare with update_shared_resource_unsafe.
#>
task update_shared_resource {
	Import-Module SplitPipeline

	# shared resource
	$data = [ref]0

	# 10 concurrent workers update the resource 10 times each
	1..100 | Split-Pipeline -Count 10 -Variable data {process{
		Use-RedisLock test:lock1 -Delay 0:0:0.001 {
			# get resource data (e.g. read file, etc.)
			$value = $data.Value

			# process data, fake some time
			Start-Sleep -Milliseconds 1

			# update data (e.g. write file, etc.)
			$data.Value = $value + 1
		}
	}}

	# 100, all updates counted
	equals $data.Value 100
}

<#
	This is an unsafe way of updating shared resource data.
	The code is from update_shared_resource, with no lock.
#>
task update_shared_resource_unsafe {
	Import-Module SplitPipeline

	# shared resource
	$data = [ref]0

	# 10 concurrent workers, 10 updates each, with no lock
	1..100 | Split-Pipeline -Count 10 -Variable data {process{
		$value = $data.Value
		Start-Sleep -Milliseconds 1
		$data.Value = $value + 1
	}}

	# <100 (usually), some updates lost
	$data.Value
	assert ($data.Value -le 99)
}

task timeout {
	Remove-RedisKey ($key = 'test:lock1')
	$span = [timespan]::FromMilliseconds(200)

	# set manual lock
	Set-RedisString $key manual -TimeToLive $span

	# cannot take lock now, timeout is less than manual TTL
	try { throw Use-RedisLock $key -Delay ($span / 3) -Timeout ($span / 2) {} }
	catch { $_; equals "$_" "Cannot take lock 'test:lock1', timeout 00:00:00.1000000." }

	# can take lock now, by this time the manual lock expires
	#! https://github.com/microsoft/garnet/issues/771
	#! used to "Cannot release lock"
	Use-RedisLock $key -Delay ($span / 3) {}

	equals (Test-RedisKey $key) 0L
}

<#
	If the script passed in Use-RedisLock fails then the error is propagated.
	The taken lock should be released.
#>
task script_fails {
	Remove-RedisKey ($key = 'test:lock1')

	try {
		Use-RedisLock $key {
			throw 'oops'
		}
		throw
	}
	catch {
		($r = $_.InvocationInfo.PositionMessage)
		assert $r.Contains("throw 'oops'")
	}

	try {
		Use-RedisLock $key {
			Get-Variable missing
		}
		throw
	}
	catch {
		($r = $_.InvocationInfo.PositionMessage)
		assert $r.Contains("Get-Variable missing")
	}

	equals (Test-RedisKey $key) 0L
}

<#
	Script output, if any, is propagated by Use-RedisLock.
#>
task script_output {
	Remove-RedisKey ($key = 'test:lock1')

	# one
	$r = Use-RedisLock $key {
		'apple'
	}
	equals $r apple

	# many
	$r = Use-RedisLock $key {
		'apple'
		'banana'
	}
	equals $r[0] apple
	equals $r[1] banana

	equals (Test-RedisKey $key) 0L
}

<#
	If the script succeeds but Use-RedisLock cannot extend the lock during
	processing then it writes an error.
#>
task cannot_extend_lock {
	Remove-RedisKey ($key = 'test:lock1')

	Use-RedisLock $key -Delay 0:0:0.1 -Timeout 0:0:0.5 -ErrorAction 0 -ErrorVariable r {
		# fake interference -> cannot extend
		Remove-RedisKey $key
		# now let extending attempt happen
		Start-Sleep -Milliseconds 500
	}

	equals "$r" "Cannot extend lock 'test:lock1'."

	equals (Test-RedisKey $key) 0L
}

<#
	If the script succeeds but Use-RedisLock cannot release the lock after
	processing then it writes an error.
#>
task cannot_release_lock {
	Remove-RedisKey ($key = 'test:lock1')

	Use-RedisLock $key -ErrorAction 0 -ErrorVariable r {
		# fake interference -> cannot release
		Remove-RedisKey $key
	}

	equals "$r" "Cannot release lock 'test:lock1'."

	equals (Test-RedisKey $key) 0L
}

<#
	Use-RedisLock terminates on invalid parameters.
#>
task invalid_input {
	try { throw Use-RedisLock test:1 -Delay 0:2 -Timeout 0:1 -ErrorAction 0 {} }
	catch { $_; equals "$_" "Delay must be less than timeout." }
}
