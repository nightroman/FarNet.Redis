
Set-StrictMode -Version 3
Import-Module FarNet.Redis

$BaseDB = @{
	parameters = @{
		Database = @'
		The database from Open-Redis, the variable $db by default.
'@
	}
}

$BaseKey = Merge-Helps $BaseDB @{
	parameters = @{
		Key = @'
		Specifies the Redis key.
'@
	}
}

$BaseKeys = Merge-Helps $BaseDB @{
	parameters = @{
		Key = @'
		Specifies one or more Redis keys.
'@
	}
}

$BaseSub = Merge-Helps $BaseDB @{
	parameters = @{
		Channel = @'
		Specifies the Redis channel.
'@
	}
}

### Open-Redis
@{
	command = 'Open-Redis'
	synopsis = 'Opens and returns the specified Redis database.'
	description = @'
	This command connects to Redis and returns the database instance. Keep it
	as the variable $db. Other commands use the variable $db as the default
	value of the parameter Database.

	You may close the database by Close-Redis.
'@
	parameters = @{
		Configuration = @'
		Specifies the Redis configuration string.
		Examples:
			"localhost:3278"
			"localhost:3278,AllowAdmin=true"
'@
	}
	outputs = @{
		type = 'StackExchange.Redis.IDatabase'
	}
	links = @(
		@{ text = 'Close-Redis' }
	)
}

### Close-Redis
Merge-Helps $BaseDB @{
	command = 'Close-Redis'
	synopsis = 'Closes the Redis database.'
	description = @'
	This command closes the database from Open-Redis.
'@
	links = @(
		@{ text = 'Open-Redis' }
	)
}

### Get-RedisServer
Merge-Helps $BaseDB @{
	command = 'Get-RedisServer'
	synopsis = 'Gets the database server instance.'
	description = ''
	outputs = @(
		@{type = 'StackExchange.Redis.IServer'}
	)
}

### Get-RedisAny
Merge-Helps $BaseKey @{
	command = 'Get-RedisAny'
	synopsis = 'Gets the specified key value.'
	description = @'
	Use this cmdlet when the type is defined as a variable or unknown.
	In other cases use the type specific cmdlets Get-Redis{Type}.
'@
	parameters = @{
		Type = @'
		Specifies the expected value type.
'@
	}
	outputs = @(
		@{type = 'System.String'}
		@{type = 'System.Collections.Generic.List[System.String]'}
		@{type = 'System.Collections.Generic.HashSet[System.String]'}
		@{type = 'System.Collections.Generic.Dictionary[System.String, System.String]'}
	)
}

### Get-RedisHash
Merge-Helps $BaseKey @{
	command = 'Get-RedisHash'
	synopsis = 'Gets the specified hash.'
	description = @'
	Without extra parameters this cmdlet gets the hash.
'@
	parameters = @{
		Count = 'Tells to get the number of items.'
	}
	outputs = @(
		@{type = 'System.Collections.Generic.Dictionary[System.String, System.String]'}
		@{type = 'System.Int64'}
	)
}

### Get-RedisList
Merge-Helps $BaseKey @{
	command = 'Get-RedisList'
	synopsis = 'Gets the specified list.'
	description = @'
	Without extra parameters this cmdlet gets the list.
'@
	parameters = @{
		Count = 'Tells to get the number of items.'
	}
	outputs = @(
		@{type = 'System.Collections.Generic.List[System.String]'}
		@{type = 'System.Int64'}
	)
}

### Get-RedisSet
Merge-Helps $BaseKey @{
	command = 'Get-RedisSet'
	synopsis = 'Gets the specified set.'
	description = @'
	Without extra parameters this cmdlet gets the set.
'@
	parameters = @{
		Count = 'Tells to get the number of items.'
	}
	outputs = @(
		@{type = 'System.Collections.Generic.HashSet[System.String]'}
		@{type = 'System.Int64'}
	)
}

### Get-RedisString
Merge-Helps $BaseKeys @{
	command = 'Get-RedisString'
	synopsis = 'Gets the specified strings.'
	description = @'
	Without extra parameters this cmdlet gets strings.
'@
	parameters = @{
		Length = 'Tells to get the string length.'
	}
	outputs = @(
		@{type = 'System.String'}
		@{type = 'System.Int64'}
	)
}

### Set-RedisHash
Merge-Helps $BaseKey @{
	command = 'Set-RedisHash'
	synopsis = 'Sets the specified hash.'
	description = ''
	parameters = @{
		Update = 'Tells to update the hash if it exists.'
		Value = 'The new hash.'
	}
}

### Set-RedisList
Merge-Helps $BaseKey @{
	command = 'Set-RedisList'
	synopsis = 'Sets the specified list.'
	description = ''
	parameters = @{
		LeftPush = 'Tells to inserts new items at the start.'
		RightPush = 'Tells to append new items to the end.'
		Value = 'The new list.'
	}
}

### Set-RedisSet
Merge-Helps $BaseKey @{
	command = 'Set-RedisSet'
	synopsis = 'Sets the specified set.'
	description = ''
	parameters = @{
		Add = 'Tells to add new items.'
		Value = 'The new set.'
	}
}

### Set-RedisString
Merge-Helps $BaseKeys @{
	command = 'Set-RedisString'
	synopsis = 'Sets the specified string.'
	description = ''
	parameters = @{
		Append = @'
		Tells to append if the string exists and get the result string length.
'@
		Decrement = @'
		Decrements the number and gets the result number.
'@
		Increment = @'
		Increments the number and gets the result number.
'@
		Expiry = @'
		Tells to set the expiry time span.
'@
		Get = @'
		Tells to atomically set the new string and return the old if any.
'@
		Value = @'
		The new string.
'@
		When = @'
		Specifies when the new value should be set and gets the result.
		The result is true or false if the value is set or not set.
		Values to use: Always or Exists.
'@
	}
	outputs = @(
		@{type = 'none'}
		@{type = 'System.Int64'}
		@{type = 'System.Double'}
		@{type = 'System.String'}
	)
}

### Get-RedisKey
Merge-Helps $BaseKey @{
	command = 'Get-RedisKey'
	synopsis = 'Gets the specified key information.'
	description = @'
	Without extra parameters this cmdlet gets the value type.
'@
	parameters = @{
		TimeToLive = 'Tells to get the time to live span.'
	}
	outputs = @(
		@{type = 'StackExchange.Redis.RedisType'}
		@{type = 'System.TimeSpan'}
	)
}

### Test-RedisKey
Merge-Helps $BaseKeys @{
	command = 'Test-RedisKey'
	synopsis = 'Checks if the specified key exists.'
	description = @'
	This command tests the specified keys and gets the number of existing.
'@
	outputs = @(
		@{type = 'System.Int64'}
	)
}

### Remove-RedisKey
Merge-Helps $BaseKeys @{
	command = 'Remove-RedisKey'
	synopsis = 'Removes the specified keys.'
	description = ''
	parameters = @{
		Result = 'Tells to get the number of removed keys.'
	}
	outputs = @(
		@{type = 'none'}
		@{type = 'System.Int64'}
	)
}

### Search-RedisKey
Merge-Helps $BaseDB @{
	command = 'Search-RedisKey'
	synopsis = 'Searches for keys matching the pattern.'
	description = ''
	parameters = @{
		Pattern = 'Specifies the search pattern.'
	}
	outputs = @(
		@{type = 'System.String'}
	)
}

### Register-RedisSub
Merge-Helps $BaseSub @{
	command = 'Register-RedisSub'
	synopsis = 'Registers the channel message handler.'
	description = @'
	This command registers the specified channel handler.
'@
	parameters = @{
		Script = @'
		The channel message handler script. The script is invoked with two
		arguments: the channel and the received string message.
'@
	}
	outputs = @(
		@{
			type = 'System.Object'
			description = 'Use this object for Unregister-RedisSub.'
		}
	)
	examples = @(
		@{ code = {
			$handler = Register-RedisSub test {
				param($channel, $message)
				Write-Host "Channel $channel received: $message"
			}

			$null = $db.Publish('test', 'Hello')

			Unregister-RedisSub test $handler
		}}
	)
	links = @(
		@{text = 'Unregister-RedisSub'}
	)
}

### Unregister-RedisSub
Merge-Helps $BaseSub @{
	command = 'Unregister-RedisSub'
	synopsis = 'Unregisters the channel subscription handler.'
	description = @'
	This command unregisters the specified channel handler or all handlers of
	the specified channel.
'@
	parameters = @{
		Handler = @'
		The object from Register-RedisSub identifying the handler. If it is
		omitted then all handlers of the specified channel are unregistered.
'@
	}
	links = @(
		@{ text = 'Register-RedisSub' }
	)
}
