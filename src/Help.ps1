
Set-StrictMode -Version 3
Import-Module FarNet.Redis

$ParamKey = 'Specifies the Redis key.'
$ParamCount = 'Gets the number of items.'
$ParamConfiguration = @'
		Specifies the Redis configuration string.
		Examples:
			"127.0.0.1:3278"
			"127.0.0.1:3278,AllowAdmin=true"

		Note that 127.0.0.1 seems to work faster than localhost.
'@
$ParamTimeToLive = @'
		Specifies the time to live.
'@
$ParamWhen = @'
		Specifies when the values should be set and returns true if keys were
		set and false otherwise.
'@

$BaseDB = @{
	parameters = @{
		Database = @'
		Specifies the database, usually returned by Open-Redis. When omitted,
		the variable $db is used if it exists, otherwise the default database
		is used if it is defined as $env:FARNET_REDIS_CONFIGURATION
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
		Specifies the Redis keys.
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

	When $env:FARNET_REDIS_CONFIGURATION is defined, you may call Open-Redis
	without parameters in order to open this kind of default database.
'@
	parameters = @{
		Configuration = $ParamConfiguration
		Prefix = @'
		Specifies the key prefix and tells to return the prefixed database.
		See Use-RedisPrefix for the details.
'@
		AllowAdmin = @'
		Tells to allow admin operations.
'@
	}
	outputs = @{
		type = 'StackExchange.Redis.IDatabase'
	}
	links = @(
		@{ text = 'Close-Redis' }
		@{ text = 'Use-RedisPrefix' }
	)
}

### Save-Redis
Merge-Helps $BaseDB @{
	command = 'Save-Redis'
	synopsis = 'Explicitly requests to persist the current state to disk.'
	description = @'
	This command calls Save(BackgroundSave) and waits for LastSave() changed.
'@
	parameters = @{
		Configuration = $ParamConfiguration
	}
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

### Use-RedisPrefix
Merge-Helps $BaseDB @{
	command = 'Use-RedisPrefix'
	synopsis = 'Gets a prefixed database.'
	description = @'
	This command returns a new database that provides an isolated key space of
	the specified underlying database. The underlying database may be prefixed,
	too, in this case the specified prefix works as sub-prefix.

	With such a prefixed database input keys are automatically prefixed for all
	commands. Note that output keys are still absolute.

	If all operations use the same key prefix then you may open the prefixed
	database right away by Open-Redis -Prefix.
'@
	parameters = @{
		Prefix = @'
		Specifies the prefix that defines a key space isolation for the
		returned database. If the underlying database is prefixed, the
		prefix works as sub-prefix.
'@
	}
	outputs = @(
		@{ type = 'StackExchange.Redis.IDatabase' }
	)
	links = @(
		@{ text = 'Open-Redis' }
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
		@{ type = 'System.String'; description = 'when key is String' }
		@{ type = 'System.Collections.Hashtable'; description = 'when key is Hash' }
		@{ type = 'System.Collections.Generic.List[System.String]'; description = 'when key is List' }
		@{ type = 'System.Collections.Generic.HashSet[System.String]'; description = 'when key is Set' }
	)
}

### Get-RedisHash
Merge-Helps $BaseKey @{
	command = 'Get-RedisHash'
	synopsis = 'Gets the hash or its details.'
	parameters = @{
		Count = $ParamCount
		Field = @'
		Gets values of the specified fields, including nulls for missing fields.

		If this parameter is omitted then the whole hash is returned as hashtable.
'@
	}
	outputs = @(
		@{ type = 'System.Collections.Hashtable' }
		@{ type = 'System.String'; description = 'with Field' }
		@{ type = 'System.Int64'; description = 'with Count' }
	)
}

### Get-RedisList
Merge-Helps $BaseKey @{
	command = 'Get-RedisList'
	synopsis = 'Gets the list items or details.'
	parameters = @{
		Count = $ParamCount
		Index = @'
		Gets an item by the specified index. Negative indexes are used to get
		items from the tail, e.g. -1 is the last item.
'@
	}
	outputs = @(
		@{ type = 'System.String' }
		@{ type = 'System.Int64'; description = 'with Count' }
	)
}

### Get-RedisSet
Merge-Helps $BaseKey @{
	command = 'Get-RedisSet'
	synopsis = 'Gets the set members or details.'
	parameters = @{
		Count = $ParamCount
	}
	outputs = @(
		@{ type = 'System.String' }
		@{ type = 'System.Int64'; description = 'with Count' }
	)
}

### Get-RedisString
Merge-Helps $BaseDB @{
	command = 'Get-RedisString'
	synopsis = 'Gets the string or its details.'
	parameters = @{
		Key = $ParamKey
		Many = @'
		Gets several specified strings.
'@
		Length = @'
		Gets the string length.
'@
	}
	outputs = @(
		@{ type = 'System.String' }
		@{ type = 'System.Int64'; description = 'with Length' }
	)
}

### Set-RedisHash
Merge-Helps $BaseKey @{
	command = 'Set-RedisHash'
	synopsis = 'Sets or updates the hash.'
	parameters = @{
		Field = @'
		Specifies the field.
'@
		Value = @'
		Specifies the field value.
'@
		When = @'
		Specifies when to set the field and gets the result:
		Always:
			true: new field
			false: updated old field
		NotExists:
			true: new field
			false: old field, not updated
'@
		Many = @'
		Specifies the fields and values.
'@
		Remove = @'
		Removes the specified fields.
'@
	}
	outputs = @(
		@{ type = 'System.Boolean'; description = 'with When' }
	)
}

### Set-RedisList
Merge-Helps $BaseKey @{
	command = 'Set-RedisList'
	synopsis = 'Sets or updates the list.'
	parameters = @{
		RightPush = @'
		Insert the specified items at the tail.
'@
		LeftPush = @'
		Insert the specified items at the head.
'@
		RightPop = @'
		Removes and returns the specified number of items at the tail.
'@
		LeftPop = @'
		Removes and returns the specified number of items at the head.
'@
	}
}

### Set-RedisNumber
Merge-Helps $BaseDB @{
	command = 'Set-RedisNumber'
	synopsis = 'Sets or updates the number.'
	parameters = @{
		Key = $ParamKey
		Value = @'
		The new number.
'@
		Increment = @'
		Increments by the specified integer and gets the result [long].
		Existing values should be integers, missing are treated as 0.
'@
		Decrement = @'
		Decrements by the specified integer and gets the result [long].
		Existing values should be integers, missing are treated as 0.
'@
		Add = @'
		Adds the specified real number and gets the result [double].
		Existing values should be numbers, missing are treated as 0.
'@
		Subtract = @'
		Subtracts the specified real number and gets the result [double].
		Existing values should be numbers, missing are treated as 0.
'@
		TimeToLive = $ParamTimeToLive
		When = $ParamWhen
	}
	outputs = @(
		@{ type = 'System.Int64'; description = 'with Increment, Decrement' }
		@{ type = 'System.Double'; description = 'with Add, Subtract' }
		@{ type = 'System.Boolean'; description = 'with When' }
	)
}

### Set-RedisSet
Merge-Helps $BaseKey @{
	command = 'Set-RedisSet'
	synopsis = 'Sets or updates the set.'
	parameters = @{
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
	synopsis = 'Sets or updates the string.'
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
		SetAndGet = @'
		Atomically sets the specified string and returns the old string.
'@
		TimeToLive = $ParamTimeToLive
		When = $ParamWhen
	}
	outputs = @(
		@{ type = 'System.String'; description = 'with SetAndGet' }
		@{ type = 'System.Boolean'; description = 'with When' }
	)
}

### Get-RedisKey
Merge-Helps $BaseKey @{
	command = 'Get-RedisKey'
	synopsis = 'Gets the key type or other details.'
	parameters = @{
		TimeToLive = 'Tells to get the time to live.'
	}
	outputs = @(
		@{ type = 'StackExchange.Redis.RedisType' }
		@{ type = 'System.TimeSpan'; description = 'with TimeToLive' }
	)
}

### Set-RedisKey
Merge-Helps $BaseKey @{
	command = 'Set-RedisKey'
	synopsis = 'Sets the specified key properties.'
	parameters = @{
		TimeToLive = @'
		Sets the specified time to live.
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
		@{ type = 'System.Int64'; description = 'with Result' }
	)
}

### Rename-RedisKey
Merge-Helps $BaseKey @{
	command = 'Rename-RedisKey'
	synopsis = 'Renames the specified key.'
	parameters = @{
		NewKey = 'Specifies the new Redis key.'
		When = @'
		Specifies when the key should be renamed and returns true if the key
		was renamed and false otherwise.
'@
	}
	outputs = @(
		@{ type = 'System.Boolean'; description = 'with When' }
	)
}

### Search-RedisKey
Merge-Helps $BaseDB @{
	command = 'Search-RedisKey'
	synopsis = 'Searches for keys matching the pattern.'
	parameters = @{
		Pattern = @'
		Specifies the search pattern in one of two forms.

		(1) Without `[` and `]`, treated as simple pattern with `*` and `?` as
		wildcard characters and all other characters as literal.

		(2) With `[` or `]`, treated as glob-style pattern with `*`, `?`, `[]`,
		`[^]` and character `\` used for escaping literal characters.
'@
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
		TimeToLive = $ParamTimeToLive
	}
}

### Wait-RedisString
Merge-Helps $BaseKey @{
	command = 'Wait-RedisString'
	synopsis = 'Waits for the string to exist and returns it.'
	description = @'
	This command periodically checks the specified string and returns its value
	as soon as it exists. When the time is out, it returns nothing.
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

### Export-Redis
Merge-Helps $BaseDB @{
	command = 'Export-Redis'
	synopsis = 'Exports data to JSON.'
	description = @'
	 By default, only persistent keys are exported. Use the parameter
	 TimeToLive in order to include appropriate expiring keys.

	 Use Import-Redis in order to import exported data.
'@
	parameters = @{
		Path = 'Specifies the output file.'
		Pattern = 'Specifies the optional key pattern.'
		TimeToLive = @'
		Tells to include expiring keys with their remaining time to live
		greater than the specified span.
'@
	}
}

### Import-Redis
Merge-Helps $BaseDB @{
	command = 'Import-Redis'
	synopsis = 'Imports data from JSON.'
	description = @'
	This command imports keys from the file created by Export-Redis.
'@
	parameters = @{
		Path = 'Specifies the input file.'
	}
}
