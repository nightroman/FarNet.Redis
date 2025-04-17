
Set-StrictMode -Version 3
Import-Module FarNet.Redis

$ParamKey = 'Specifies the Redis key.'

$ParamCount = 'Gets the number of items.'

$ParamPattern = @'
		Specifies the search pattern in one of two forms.

		(1) Without `[` and `]`, treated as simple pattern with `*` and `?` as
		wildcard characters and all other characters as literal.

		(2) With `[` or `]`, treated as glob-style pattern with `*`, `?`, `[]`,
		`[^]` and character `\` used for escaping literal characters.
'@

$ParamTimeToLive = @'
		Specifies the time to live.
'@

$ParamWhen = @'
		Specifies when the values should be set and returns true if keys were
		set and false otherwise.
'@

$ParamIncrement = @'
		Increments by the specified integer and gets the result [long].
		Existing values should be integers, missing are treated as 0.
'@

$ParamDecrement = @'
		Decrements by the specified integer and gets the result [long].
		Existing values should be integers, missing are treated as 0.
'@

$ParamAdd = @'
		Adds the specified real number and gets the result [double].
		Existing values should be numbers, missing are treated as 0.
'@

$ParamSubtract = @'
		Subtracts the specified real number and gets the result [double].
		Existing values should be numbers, missing are treated as 0.
'@

### Base

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
	This command connects to Redis and returns the specified database.

	Keep the result database as the variable $db. In this case Redis cmdlets
	automatically use it the default value of omitted parameters Database.

	Use different variables on opening more databases in the same scope and use
	them explicitly as Redis cmdlet parameters Database.

	The database may be closed by Close-Redis but in many cases this is not
	needed. It is cached internally and automatically reused on Open-Redis
	subsequent calls with the same Configuration.
'@
	parameters = @{
		Configuration = @'
		Specifies the configuration, see https://stackexchange.github.io/StackExchange.Redis/Configuration

		If Configuration is omitted then $env:FARNET_REDIS_CONFIGURATION is
		used as the default configuration. This variable should be defined
		or else the call fails.

		EXAMPLES

		127.0.0.1:3278
		"127.0.0.1:3278,allowAdmin=true"
		"127.0.0.1:3278,defaultDatabase=1"

		NOTES

		In local endpoints 127.0.0.1 seems to work faster than localhost.

		`defaultDatabase=N` maybe used instead of specifying -Index N.

		With multiple endpoints ("server1:6379,server2:6379") the first
		endpoint defines the server which is used by these cmdlets:

			- Search-RedisKey
			- Get-RedisServer
			- Save-Redis
'@
		Index = @'
		Specifies the database index. The default -1 implies the default
		database if it is specified by Configuration, otherwise it is 0.
'@
		Prefix = @'
		Specifies the key prefix and tells to return the prefixed database.
		See Use-RedisPrefix for the details.
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
}

### Clear-Redis
Merge-Helps $BaseDB @{
	command = 'Clear-Redis'
	synopsis = 'Removes all database keys.'
	description = @'
	This command removes all database keys.
'@
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
		Pattern = @"
$ParamPattern

		The result is Hashtable of found keys and values.
"@
		TimeToLive = @'
		Tells to get times to live for the specified fields as [timespan].

		Special cases:
		- [timespan](-1) time to live not set
		- [timespan](-2) field does not exist
'@
	}
	outputs = @(
		@{ type = 'System.Collections.Hashtable' }
		@{ type = 'System.String'; description = 'with Field' }
		@{ type = 'System.Int64'; description = 'with Count' }
		@{ type = 'System.TimeSpan'; description = 'with TimeToLive' }
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
		Pattern = @"
$ParamPattern

		The result is strings matching the pattern.
"@
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
		TimeToLive = @'
		Tells to update the time to live.
		Null will remove expiry.
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
		Specifies the fields to remove.
'@
		Persist = @'
		Specifies the fields to persist or set their times to live.
'@
		TimeToLive = @'
		With Persist, specifies the time to live to be set.
'@
		Increment = $ParamIncrement
		Decrement = $ParamDecrement
		Add = $ParamAdd
		Subtract = $ParamSubtract
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
		TimeToLive = $ParamTimeToLive
		When = $ParamWhen
		Increment = $ParamIncrement
		Decrement = $ParamDecrement
		Add = $ParamAdd
		Subtract = $ParamSubtract
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

		All given keys are set at once or none.
'@
		Append = @'
		Appends the string and returns result length if Result is set.
'@
		Result = @'
		Tells to return the result.
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
		@{ type = 'System.Int64'; description = 'with Append and Result' }
	)
}

### Get-RedisKey
Merge-Helps $BaseKey @{
	command = 'Get-RedisKey'
	synopsis = 'Gets the key type or details.'
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
		Pattern = $ParamPattern
	}
	outputs = @(
		@{ type = 'System.String' }
	)
}

### Add-RedisHandler
Merge-Helps $BaseSub @{
	command = 'Add-RedisHandler'
	synopsis = 'Subscribes to the channel messages.'
	description = @'
	This command adds the handler of the channel messages and returns the
	object that may be used for removing this handler.
'@
	parameters = @{
		Handler = @'
		The channel message handler script. The script is invoked with two
		arguments: the channel and string message.
'@
	}
	outputs = @(
		@{
			type = 'System.Object'
			description = 'Use this object for Remove-RedisHandler.'
		}
	)
	examples = @(
		@{ code = {
			$handler = Add-RedisHandler test {
				param($channel, $message)
				Write-Host "Channel $channel received: $message"
			}

			$null = $db.Publish('test', 'Hello')

			Remove-RedisHandler test $handler
		}}
	)
	links = @(
		@{ text = 'Send-RedisMessage' }
		@{ text = 'Remove-RedisHandler' }
	)
}

### Send-RedisMessage
Merge-Helps $BaseSub @{
	command = 'Send-RedisMessage'
	synopsis = 'Posts a message to the given channel.'
	description = @'
	Posts a message to the given channel.
'@
	parameters = @{
		Message = @'
		Specifies the message to post.
'@
		Result = @'
		Tells to return the number of clients that the message was sent to.
		In a Redis cluster, only clients connected to the same node as the
		publishing client are included.
'@
	}
	outputs = @(
		@{ type = 'System.Int64'; description = 'with Result' }
	)
	links = @(
		@{ text = 'Add-RedisHandler' }
		@{ text = 'Remove-RedisHandler' }
	)
}

### Remove-RedisHandler
Merge-Helps $BaseSub @{
	command = 'Remove-RedisHandler'
	synopsis = 'Unsubscribes from the specified channel.'
	description = @'
	This command removes the handler or all handlers from the specified channel.
'@
	parameters = @{
		Handler = @'
		The object from Add-RedisHandler identifying the handler. If it is
		omitted then all handlers of the specified channel are unregistered.
'@
	}
	links = @(
		@{ text = 'Add-RedisHandler' }
		@{ text = 'Send-RedisMessage' }
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
		Exclude = @'
		Tells to exclude keys matching the specified wildcard patterns.
'@
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

### Merge-RedisSet
Merge-Helps $BaseDB @{
	command = 'Merge-RedisSet'
	synopsis = 'Combines the specified sets.'
	description = @'
	This command performs Union, Intersect, Difference operations with the
	given source sets. Use the switch Destination in order to store results
	as the new set.
'@
	parameters = @{
		Operation = @'
		Specifies one of the set operations:

		Union
			Returns the members of the set resulting from the union of all the
			given sets.

		Intersect
			Returns the members of the set resulting from the intersection of
			all the given sets.

		Difference
			Returns the members of the set resulting from the difference
			between the first set and all the successive sets.

		Keys that do not exist are treated as empty sets.
'@
		Source = @'
		Specifies the source set keys.
		Keys that do not exist are treated as empty sets.
'@
		Destination = @'
		Tells to store the result as the specified set.
		If the destination key exists, it is overwritten.
'@
		Result = @'
		With Destination, tells to return the result number of elements.
'@
	}
	outputs = @(
		@{ type = 'System.String' }
		@{ type = 'System.Int64'; description = 'with Destination + Result' }
	)
}

### New-RedisTransaction
Merge-Helps $BaseDB @{
	command = 'New-RedisTransaction'
	synopsis = 'Creates a transaction builder.'
	description = @'
	Use this cmdlet together with Invoke-RedisTransaction in order to avoid
	some known PowerShell pitfalls.
'@
	outputs = @(
		@{ type = 'StackExchange.Redis.ITransaction' }
	)
}

### Invoke-RedisTransaction
@{
	command = 'Invoke-RedisTransaction'
	synopsis = 'Executes the transaction.'
	description = @'
	This command executes the transaction and returns true if the transaction
	was committed and false otherwise.

	Use this cmdlet in order to avoid some known PowerShell pitfalls.
'@
	parameters = @{
		Transaction = @'
		Specifies the transaction builder, for example from New-RedisTransaction.
'@
	}
	outputs = @(
		@{ type = 'System.Boolean' }
	)
}

### Use-RedisLock
Merge-Helps $BaseKey @{
	command = 'Use-RedisLock'
	synopsis = 'Invokes the script with the lock.'
	description = @'
	This command attempts taking the lock for the specified key and time.
	If the lock is taken then the script is invoked, otherwise the command
	fails.

	When the script completes, successfully or not, the lock is released.

	The lock expiry is extended automatically during the script work.
	The parameter Timeout is used as the estimated initial expiry.
'@
	parameters = @{
		Script = @'
		Specifies the script block invoked with the lock.
'@
		Delay = @'
		Time to sleep between the lock taking attempts.
		Default: 1 second
'@
		Timeout = @'
		Total time for the lock taking attempts.
		Default: 1 minute
'@
		Value = @'
		The optional lock value.
		Default: 16 generated bytes
'@
	}
	outputs = @(
		@{ type = 'System.Management.Automation.PSObject'; description = 'Script output, if any' }
	)
}

### Invoke-RedisScript
Merge-Helps $BaseDB @{
	command = 'Invoke-RedisScript'
	synopsis = 'Executes Lua scripts against the server.'
	description = @'
	This command executes the script against the server and returns the result.
'@
	parameters = @{
		Script = @'
		The normal Lua script to execute.

		Normal Lua scripts use KEYS and ARGV arrays of keys and values provided
		by the parameters Keys and Argv.
'@
		Keys = @'
		Provides the keys referenced by Script as KEYS[1], KEYS[2], ...
'@
		Argv = @'
		Provides the values referenced by Script as ARGV[1], ARGV[2], ...
'@
		LuaScript = @'
		The prepared Lua script to execute, either string (to be prepared) or
		StackExchange.Redis.LuaScript (already prepared).

		Prepared scripts use @name parameter notation instead of KEYS and ARGV.
		Values are provided by the parameter Parameters properties and fields.
'@
		Parameters = @'
		An object with properties or fields referenced by LuaScript.
		All parameters referenced by the script must be available.
'@
	}
	outputs = @(
		@{ type = 'StackExchange.Redis.RedisResult' }
	)
}
