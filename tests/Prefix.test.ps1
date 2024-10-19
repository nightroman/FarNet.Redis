﻿
. ./About.ps1

# Using new scopes &{} and variables $db implicitly
task new_db_scopes {
	& {
		$db = Use-RedisPrefix test:prefix:
		Set-RedisString name Joe

		& {
			$db = Use-RedisPrefix meta:
			Set-RedisString age 42

			equals (Get-RedisString age) '42'
		}

		equals (Get-RedisString name) Joe
		equals (Get-RedisString meta:age) '42'
	}

	equals (Get-RedisString test:prefix:name) Joe
	equals (Get-RedisString test:prefix:meta:age) '42'

	Remove-RedisKey test:prefix:name, test:prefix:meta:age
}

# Using new prefixed database variables explicitly
task new_db_variables {
	$db2 = Use-RedisPrefix test:prefix:
	Set-RedisString name Joe -Database $db2

	$db3 = Use-RedisPrefix meta: -Database $db2
	Set-RedisString age 42 -Database $db3

	equals (Get-RedisString age -Database $db3) '42'

	equals (Get-RedisString name -Database $db2) Joe
	equals (Get-RedisString meta:age -Database $db2) '42'

	equals (Get-RedisString test:prefix:name) Joe
	equals (Get-RedisString test:prefix:meta:age) '42'

	Remove-RedisKey test:prefix:name, test:prefix:meta:age
}

task open_with_prefix {
	Remove-RedisKey test:2024-10-19-0637
	& {
		$db = Open-Redis -Prefix test:
		Set-RedisString 2024-10-19-0637 v1
		equals (Get-RedisString 2024-10-19-0637) v1
	}
	equals (Get-RedisString test:2024-10-19-0637) v1
	& {
		$db = Open-Redis -Prefix test:
		equals (Remove-RedisKey 2024-10-19-0637 -Result) 1L
	}
	equals (Test-RedisKey test:2024-10-19-0637) 0L
}