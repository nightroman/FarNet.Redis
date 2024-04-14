
Set-StrictMode -Version 3
Import-Module FarNet.Redis

$ParamKey = 'Specifies the Redis key.'
$ParamCount = 'Gets the number of items.'

$BaseDB = @{
	parameters = @{
		Database = @'
		The database from Open-Redis, the variable $db by default.
'@
	}
}

$BaseKey = Merge-Helps $BaseDB @{
	parameters = @{
		Key = $ParamKey
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

	You may close the database by Close-Redis. Or keep it for using later. If
	you use the same configuration string then the same database instance is
	returned.
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
	outputs = @(
		@{ type = 'StackExchange.Redis.IServer' }
	)
}

### Get-RedisAny
Merge-Helps $BaseKey @{
	command = 'Get-RedisAny'
	synopsis = 'Gets the specified key value.'
	description = @'
	Use this command when a type is unknown or defined as a variable.
	When the type is known, use type specific cmdlets Get-Redis{Type}.
'@
	parameters = @{
		Type = @'
		Specifies the expected value type.
'@
	}
	outputs = @(
		@{ type = 'System.String' }
		@{ type = 'System.Collections.Generic.List[System.String]' }
		@{ type = 'System.Collections.Generic.HashSet[System.String]' }
		@{ type = 'System.Collections.Generic.Dictionary[System.String, System.String]' }
	)
}

### Get-RedisHash
Merge-Helps $BaseKey @{
	command = 'Get-RedisHash'
	synopsis = 'Gets the hash or its details.'
	parameters = @{
		Count = $ParamCount
	}
	outputs = @(
		@{ type = 'System.Collections.Generic.Dictionary[System.String, System.String]' }
		@{ type = 'System.Int64' }
	)
}

### Get-RedisList
Merge-Helps $BaseKey @{
	command = 'Get-RedisList'
	synopsis = 'Gets the list or its details.'
	parameters = @{
		Count = $ParamCount
		Index = @'
		Gets an item by the specified index. Negative indexes are used to get
		items from the tail, e.g. -1 is the last item.
'@
	}
	outputs = @(
		@{ type = 'System.Collections.Generic.List[System.String]' }
		@{ type = 'System.String' }
		@{ type = 'System.Int64' }
	)
}

### Get-RedisSet
Merge-Helps $BaseKey @{
	command = 'Get-RedisSet'
	synopsis = 'Gets the set or its details.'
	parameters = @{
		Count = $ParamCount
	}
	outputs = @(
		@{ type = 'System.Collections.Generic.HashSet[System.String]' }
		@{ type = 'System.Int64' }
	)
}

### Get-RedisString
Merge-Helps $BaseKeys @{
	command = 'Get-RedisString'
	synopsis = 'Gets the string or its details.'
	parameters = @{
		Length = 'Gets the string length.'
	}
	outputs = @(
		@{ type = 'System.String' }
		@{ type = 'System.Int64' }
	)
}

### Set-RedisHash
Merge-Helps $BaseKey @{
	command = 'Set-RedisHash'
	synopsis = 'Sets or updates the specified hash.'
	parameters = @{
		Value = @'
		The new hash.
'@
		Delete = @'
		Removes the specified hash fields.
'@
		Set = @'
		Sets the specified hash entries.
'@
	}
}

### Set-RedisList
Merge-Helps $BaseKey @{
	command = 'Set-RedisList'
	synopsis = 'Sets or updates the specified list.'
	parameters = @{
		Value = @'
		The new list.
'@
		LeftPush = @'
		Insert the specified items at the head.
'@
		RightPush = @'
		Insert the specified items at the tail.
'@
		LeftPop = @'
		Removes and returns the specified number of items at the head.
'@
		RightPop = @'
		Removes and returns the specified number of items at the tail.
'@
	}
}

### Set-RedisSet
Merge-Helps $BaseKey @{
	command = 'Set-RedisSet'
	synopsis = 'Sets or updates the specified set.'
	parameters = @{
		Value = @'
		The new set.
'@
		Add = @'
		Adds the specified items.
'@
		Remove = @'
		Removes the specified items.
'@
	}
}

### Set-RedisString
Merge-Helps $BaseDB @{
	command = 'Set-RedisString'
	synopsis = 'Sets or updates the specified string.'
	parameters = @{
		Key = $ParamKey
		Value = @'
		The new string.
'@
		Many = @'
		Sets several strings specified as hashtable or dictionary.
'@
		Append = @'
		Appends the specified string and gets the result string length.
'@
		Increment = @'
		Increments by the specified number and gets the result integer.
'@
		Decrement = @'
		Decrements by the specified number and gets the result integer.
'@
		SetAndGet = @'
		Atomically sets the specified string and return the old string.
'@
		Expiry = @'
		Specifies the expiry time span.
'@
		When = @'
		Specifies when the values should be set and returns true if keys were
		set and false otherwise.
'@
	}
	outputs = @(
		@{ type = 'none' }
		@{ type = 'System.Int64' }
		@{ type = 'System.Double' }
		@{ type = 'System.String' }
	)
}

### Get-RedisKey
Merge-Helps $BaseKey @{
	command = 'Get-RedisKey'
	synopsis = 'Gets the key type or other details.'
	parameters = @{
		TimeToLive = 'Tells to get the time to live span.'
	}
	outputs = @(
		@{ type = 'StackExchange.Redis.RedisType' }
		@{ type = 'System.TimeSpan' }
	)
}

### Set-RedisKey
Merge-Helps $BaseKey @{
	command = 'Set-RedisKey'
	synopsis = 'Sets the specified key properties.'
	parameters = @{
		Expire = @'
		Sets the specified time span to live.
		Use null in order to persist the key.
'@
	}
}

### Test-RedisKey
Merge-Helps $BaseKeys @{
	command = 'Test-RedisKey'
	synopsis = 'Checks if the specified key exists.'
	description = @'
	This command tests the specified keys and gets the number of existing.
'@
	outputs = @(
		@{ type = 'System.Int64' }
	)
}

### Remove-RedisKey
Merge-Helps $BaseKeys @{
	command = 'Remove-RedisKey'
	synopsis = 'Removes the specified keys.'
	parameters = @{
		Result = 'Tells to get the number of removed keys.'
	}
	outputs = @(
		@{ type = 'none' }
		@{ type = 'System.Int64' }
	)
}

### Search-RedisKey
Merge-Helps $BaseDB @{
	command = 'Search-RedisKey'
	synopsis = 'Searches for keys matching the pattern.'
	parameters = @{
		Pattern = 'Specifies the search pattern.'
	}
	outputs = @(
		@{ type = 'System.String' }
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

### Get-RedisClixml
Merge-Helps $BaseKey @{
	command = 'Get-RedisClixml'
	synopsis = 'Restores an object from CLIXML string.'
	outputs = @(
		@{ type = 'System.Object' }
	)
}

### Set-RedisClixml
Merge-Helps $BaseKey @{
	command = 'Set-RedisClixml'
	synopsis = 'Stores an object as CLIXML string.'
	parameters = @{
		Value = @'
		Specifies the object to be serialized and stored as CLIXML string.
'@
		Depth = @'
		Specifies how many levels of contained objects are included in the XML
		representation. Default: 1.
'@
		Expiry = @'
		Tells to set the expiry time span.
'@
	}
}

### Wait-RedisString
Merge-Helps $BaseKey @{
	command = 'Wait-RedisString'
	synopsis = 'Waits for the string to exist and returns it.'
	description = @'
	This command periodically checks the specified string for existence and
	returns its value or none if the time is out.
'@
	parameters = @{
		Delay = 'Time to sleep between checks.'
		Timeout = 'Total time to wait.'
	}
	outputs = @(
		@{ type = 'none'; description = 'The time is out.' }
		@{ type = 'System.String'; description = 'The existing string.' }
	)
}
