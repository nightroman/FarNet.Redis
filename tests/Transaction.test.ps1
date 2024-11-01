<#
	New-RedisTransaction and Invoke-RedisTransaction work around PowerShell pitfalls.
#>

. ./About.ps1

<#
	The transaction example from StackExchange.Redis documentation
	https://stackexchange.github.io/StackExchange.Redis/Transactions
#>
task transaction-done {
	$key = 'test:1'
	Remove-RedisKey $key

	# create a new transaction
	$tr = New-RedisTransaction

	# add conditions, invoke async operations
	$null = $tr.AddCondition([StackExchange.Redis.Condition]::HashNotExists($key, 'id'))
	$null = $tr.HashSetAsync($key, 'id', '42')

	# execute the transaction, check the result
	$committed = Invoke-RedisTransaction $tr
	equals $committed $true

	equals (Get-RedisHash $key id) '42'
	Remove-RedisKey $key
}

<#
	Example of not done transaction
#>
task transaction-not-done {
	$key = 'test:1'
	Remove-RedisKey $key

	$tr = New-RedisTransaction
	$null = $tr.AddCondition([StackExchange.Redis.Condition]::HashNotExists($key, 'id'))
	$null = $tr.HashSetAsync($key, 'id', '42')

	# fake intervention
	Set-RedisHash $key id 33

	# execute the transaction, not committed
	$committed = Invoke-RedisTransaction $tr
	equals $committed $false

	equals (Get-RedisHash $key id) '33'
	Remove-RedisKey $key
}

<#
	Pure PowerShell transaction example

	Mind using `Execute([StackExchange.Redis.CommandFlags]::None)`:
	- `Execute()` calls a different method in the actual class
	- `Execute('None')` fails with an odd error
#>
task how-to-use-transaction {
	$key = 'test:1'
	Remove-RedisKey $key

	$tr = $db.CreateTransaction($null)
	$null = $tr.AddCondition([StackExchange.Redis.Condition]::HashNotExists($key, 'id'))
	$null = $tr.HashSetAsync($key, 'id', '42')
	$committed = $tr.Execute([StackExchange.Redis.CommandFlags]::None)
	equals $committed $true

	$r = Get-RedisHash $key id
	equals $r '42'

	Remove-RedisKey $key
}

<#
	PowerShell pitfalls example 1

	`Execute()` with no parameters calls `void StackExchange.Redis.RedisTransaction.Execute()`,
	not the expected `bool ITransaction.Execute(CommandFlags flags = CommandFlags.None)`.
	The former calls `Execute(CommandFlags.FireAndForget)`, not `Execute(None)`.

	Thus, we cannot check the result, it is always null (works like $false).
#>
task do-not-Execute-with-no-parameter {
	$key = 'test:1'
	Remove-RedisKey $key

	$tr = $db.CreateTransaction($null)
	$null = $tr.AddCondition([StackExchange.Redis.Condition]::HashNotExists($key, 'id'))
	$null = $tr.HashSetAsync($key, 'id', '42')
	$committed = $tr.Execute()
	if ($committed) {
		# this is never called
		throw
	}
	else {
		# "looks not committed" but it is
		equals (Get-RedisHash $key id) '42'
	}

	Remove-RedisKey $key
}

<#
	PowerShell pitfalls example 2

	In theory `Execute('None')` should work around the above issue but it fails oddly.
	So use transaction cmdlets or `Execute([StackExchange.Redis.CommandFlags]::None)`.
#>
task do-not-Execute-with-string-None {
	$key = 'test:1'
	Remove-RedisKey $key

	$tr = $db.CreateTransaction($null)
	$null = $tr.AddCondition([StackExchange.Redis.Condition]::HashNotExists($key, 'id'))
	$null = $tr.HashSetAsync($key, 'id', '42')
	try { throw $tr.Execute('None') }
	catch { $_; assert ($_ -match 'ExecuteSync cannot be used inside a transaction') }

	equals (Test-RedisKey $key) 0L
}
