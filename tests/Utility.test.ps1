
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
	Set-RedisString try:t1 привет
	Set-RedisString try:b1 $blob
	Set-RedisString try:t2 привет -TimeToLive ([timespan]::FromMinutes(3))
	Set-RedisString try:b2 $blob -TimeToLive ([timespan]::FromMinutes(3))
	Set-RedisHash try:h1 ([ordered]@{привет=42; world=$blob})
	Set-RedisList try:l1 привет, $blob
	Set-RedisSet try:s1 $blob, привет
	Set-RedisString try:short lived -TimeToLive ([timespan]::FromMinutes(1))

	# export with expiring
	Export-Redis z.1.json try:* -TimeToLive ([timespan]::FromMinutes(2))

	# test expected JSON
	$r = Get-Content z.1.json -Raw | ConvertFrom-Json -AsHashtable
	equals $r.Count 7
	equals $r['try:t1'] привет
	equals $r['try:b1'][0] $base64
	equals $r['try:t2'].Text привет
	equals $r['try:b2'].Blob $base64
	equals $r['try:h1'].Hash.привет '42'
	equals $r['try:h1'].Hash.world[0] $base64
	equals $r['try:l1'].List[0] привет
	equals $r['try:l1'].List[1][0] $base64
	equals $r['try:s1'].Set[0][0] $base64
	equals $r['try:s1'].Set[1] привет
	assert ($r['try:t2'].EOL -match '^\d\d\d\d-\d\d-\d\d \d\d:\d\d$')
	assert ($r['try:b2'].EOL -match '^\d\d\d\d-\d\d-\d\d \d\d:\d\d$')

	# import and export again, persistent only this time
	Import-Redis z.1.json
	Export-Redis z.2.json try:*

	# expiring keys were excluded
	$r = Get-Content z.2.json -Raw | ConvertFrom-Json -AsHashtable
	equals (($r.Keys | Sort-Object) -join ',') 'try:b1,try:h1,try:l1,try:s1,try:t1'

	# test expected formatting, mind random order
	$r = (Get-Content z.1.json) -join '|' -replace '\d\d\d\d-\d\d-\d\d \d\d:\d\d', 'date' -replace ','
	assert $r.Contains('|  "try:t1": "привет"|')
	assert $r.Contains('|  "try:b1": ["AIA="]|')
	assert $r.Contains('|  "try:t2": {|    "EOL": "date"|    "Text": "привет"|  }|')
	assert $r.Contains('|  "try:b2": {|    "EOL": "date"|    "Blob": "AIA="|  }|')
	assert $r.Contains('|  "try:h1": {|    "Hash": {|      "привет": "42"|      "world": ["AIA="]|    }|  }|')
	assert $r.Contains('|  "try:l1": {|    "List": [|      "привет"|      ["AIA="]|    ]|  }|')
	assert $r.Contains('|  "try:s1": {|    "Set": [|      ["AIA="]|      "привет"|    ]|  }|')

	Remove-RedisKey (Search-RedisKey try:*)
	remove z.*.json
}

task export_empty {
	$key = 'test:1'
	Set-RedisString $key ''
	Export-Redis z.json $key
	$r = ConvertFrom-Json (Get-Content z.json -Raw) -AsHashtable
	equals $r.Count 1
	equals $r[$key] ''
	Remove-RedisKey $key
	remove z.json
}

task export_exclude {
	$1, $2, $3 = 'test:wild-1', 'test:wild-apple', 'test:wild-banana'
	Set-RedisString -Many @{$1 = 1; $2 = 2; $3 = 3}
	Export-Redis z.json test:wild-* -Exclude *-app*, *nana
	$r = ConvertFrom-Json (Get-Content z.json -Raw) -AsHashtable
	equals $r.Count 1
	equals $r[$1] '1'
	Remove-RedisKey $1, $2, $3
	remove z.json
}

task 'Missing key should return null, not empty collection.' {
	$r = Get-RedisHash missing
	equals $r $null

	$r = Get-RedisList missing
	equals $r $null

	$r = Get-RedisSet missing
	equals $r $null
}

task 'Mismatch key should return null, not empty collection.' {
	$key = 'test:1'
	Set-RedisString $key 1

	$r = Get-RedisHash $key
	equals $r $null

	$r = Get-RedisList $key
	equals $r $null

	$r = Get-RedisSet $key
	equals $r $null

	Remove-RedisKey $key
}

task merge_set {
	Remove-RedisKey ($key1 = 'test:1'), ($key2 = 'test:2'), ($key3 = 'test:3')
	Set-RedisSet $key1 apple, banana
	Set-RedisSet $key2 banana, orange

	# no destination

	$r = Merge-RedisSet Intersect $key1, $key2
	equals $r banana

	$r = Merge-RedisSet Difference $key1, $key2
	equals $r apple

	$r = Merge-RedisSet Union $key1, $key2
	equals "$r" 'apple banana orange'

	# destination

	$r = Merge-RedisSet Intersect $key1, $key2 -Destination $key3
	equals $r $null
	$r = Get-RedisSet $key3
	equals $r banana

	$r = Merge-RedisSet Difference $key1, $key2 -Destination $key3
	equals $r $null
	$r = Get-RedisSet $key3
	equals $r apple

	$r = Merge-RedisSet Union $key1, $key2 -Destination $key3 -Result
	equals $r 3L
	$r = Get-RedisSet $key3
	equals "$r" 'apple banana orange'

	Remove-RedisKey $key1, $key2, $key3
}
