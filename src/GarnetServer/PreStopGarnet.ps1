<#
.Synopsis
	Pre-stop Garnet service callback.
#>

[CmdletBinding()]
param(
	[int]$Port = 3278
	,
	[string]$Log = "C:\TEMP\PreStopGarnet.log"
)

$ErrorActionPreference=1

Start-Transcript -Path $Log -Append -UseMinimalHeader
try {
	Write-Host (Get-Date) Save Redis database...

	Import-Module FarNet.Redis
	Save-Redis -Database (Open-Redis "127.0.0.1:$Port,allowAdmin=true")

	Write-Host (Get-Date) Save Redis database.
}
finally {
	Stop-Transcript
}
