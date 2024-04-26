
. ./About.ps1

task open_redis {
	# should be the same instance
	$db2 = Open-Redis 127.0.0.1:3278
	equals ([object]::ReferenceEquals($db2, $db)) $true

	# should be a different instance, close it
	$db2 = Open-Redis 127.0.0.1:3278 -AllowAdmin
	equals ([object]::ReferenceEquals($db2, $db)) $false
	Close-Redis -Database $db2
}

<#
	Set-RedisClixml and Get-RedisClixml provide low ceremony persistence of PowerShell objects.
	See the similar Export-Clixml and Import-Clixml for concepts and examples.

	NOTE:
	ConvertTo-Json and ConvertFrom-Json provide better performance.
	But the supported data types are not that rich as with CLIXML.
#>
task clixml_flat {
	$key = 'test:1'

	$data = @{
		Null = $null
		True = $true
		Int = 42
		Long = 42L
		Double = 3.14
		String = 'hello'
		DateTime = [datetime]'2024-04-13'
		TimeSpan = [timespan]::FromSeconds(42)
		Guid = [guid]'3a06ad4e-0721-4d76-814f-2220d11a689f'
		Version = [version]'1.2.3'
	}

	Set-RedisClixml $key $data
	$r = Get-RedisClixml $key

	equals $r.Null $null
	equals $r.True $true
	equals $r.Int 42
	equals $r.Long 42L
	equals $r.Double 3.14
	equals $r.String hello
	equals $r.DateTime $data.DateTime
	equals $r.TimeSpan $data.TimeSpan
	equals $r.Guid $data.Guid
	equals $r.Version $data.Version

	Remove-RedisKey $key
}

<#
	Depth 1 does not mean excluded nested objects.
	For example this test preserves 3 levels.
#>
task clixml_deep {
	$key = 'test:1'

	$data = @{
		t1 = @{
			t2 = @{
				t3 = @{
					Version = $Host.Version
				}
			}
		}
		o1 = [pscustomobject]@{
			o2 = [pscustomobject]@{
				o3 = [pscustomobject] @{
					Version = $Host.Version
				}
			}
		}
	}

	Set-RedisClixml $key $data -Depth 1

	$r = Get-RedisClixml $key
	equals $r.t1.t2.t3.Version $Host.Version
	equals $r.o1.o2.o3.Version $Host.Version
	assert ($r.t1 -is [hashtable])
	assert ($r.o1 -is [pscustomobject])

	Remove-RedisKey $key
}

task export {
	[byte[]]$blob = 0, 128
	$base64 = [Convert]::ToBase64String($blob)
	(Search-RedisKey try:*).ForEach{Remove-RedisKey $_}

	# set all types, one with expiry
	Set-RedisString try:t1 hello
	Set-RedisString try:b1 $blob
	Set-RedisString try:t2 hello -Expiry ([timespan]::FromMinutes(3))
	Set-RedisString try:b2 $blob -Expiry ([timespan]::FromMinutes(3))
	Set-RedisHash try:h1 ([ordered]@{hello=42; world=$blob})
	Set-RedisList try:l1 hello, $blob
	Set-RedisSet try:s1 $blob, hello
	Set-RedisString try:short lived -Expiry ([timespan]::FromMinutes(1))

	# export with expiring
	Export-Redis z.1.json try:* -TimeToLive ([timespan]::FromMinutes(2))

	# test expected JSON
	$r = Get-Content z.1.json -Raw | ConvertFrom-Json -AsHashtable
	equals $r.Count 7
	equals $r['try:t1'] hello
	equals $r['try:b1'][0] $base64
	equals $r['try:t2'].Text hello
	equals $r['try:b2'].Blob $base64
	equals $r['try:h1'].Hash.hello '42'
	equals $r['try:h1'].Hash.world[0] $base64
	equals $r['try:l1'].List[0] hello
	equals $r['try:l1'].List[1][0] $base64
	equals $r['try:s1'].Set[0][0] $base64
	equals $r['try:s1'].Set[1] hello
	assert ($r['try:t2'].EOL -is [datetime])
	assert ($r['try:b2'].EOL -is [datetime])

	# import and export again, persistent only this time
	Import-Redis z.1.json
	Export-Redis z.2.json try:*

	# expiring keys were excluded
	$r = Get-Content z.2.json -Raw | ConvertFrom-Json -AsHashtable
	equals (($r.Keys | Sort-Object) -join ',') 'try:b1,try:h1,try:l1,try:s1,try:t1'

	# test expected formatting, mind random order
	$r = (Get-Content z.1.json) -join '|' -replace '\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d', 'date' -replace ','
	assert $r.Contains('|  "try:t1": "hello"|')
	assert $r.Contains('|  "try:b1": ["AIA="]|')
	assert $r.Contains('|  "try:t2": {|    "EOL": "date"|    "Text": "hello"|  }|')
	assert $r.Contains('|  "try:b2": {|    "EOL": "date"|    "Blob": "AIA="|  }|')
	assert $r.Contains('|  "try:h1": {|    "Hash": {|      "hello": "42"|      "world": ["AIA="]|    }|  }|')
	assert $r.Contains('|  "try:l1": {|    "List": [|      "hello"|      ["AIA="]|    ]|  }|')
	assert $r.Contains('|  "try:s1": {|    "Set": [|      ["AIA="]|      "hello"|    ]|  }|')

	Remove-RedisKey (Search-RedisKey try:*)
	remove z.*.json
}
