<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build

.Description
	Tasks to build and maintain the service "garnet".
	Requires: https://github.com/aelassas/servy
#>

$Port = 3278
$ServiceName = 'garnet'
$AppRoot = 'C:\Bin\Garnet'
$DataRoot = 'C:\Data\Garnet'
$Log = "$DataRoot\service.log"
$App = "$AppRoot\GarnetServer.exe"
$Params = @(
	"--port=$Port"
	"--checkpointdir=$DataRoot\checkpointdir"
	'--index=128m'
	'--obj-index=16m'
	'--max-databases=2'
	'--lua'
	'--lua-transaction-mode'
	'-q'
	'--recover'
	'--logger-level=Information'
) -join ' '

task run {
	Start-Process $App $Params
}

task publish {
	remove $AppRoot
	exec { dotnet publish --use-current-runtime -c Release -o $AppRoot }
	remove bin, obj
}

# - AutomaticDelayedStart // let required network services start first
# - DOTNET_LegacyExceptionHandling // https://github.com/microsoft/garnet/issues/902
task install {
	$pwsh = (Get-Command pwsh.exe).Definition
	exec -echo {
		servy-cli install `
		--name=$ServiceName `
		--path=$App `
		--params=$Params `
		--startupDir=$AppRoot `
		--startupType=AutomaticDelayedStart `
		--env="DOTNET_LegacyExceptionHandling=1" `
		--stdout=$Log `
		--stderr=$Log `
		--preStopPath=$pwsh `
		--preStopParams="-nop -c Import-Module FarNet.Redis; Save-Redis -Database (Open-Redis '127.0.0.1:$Port,allowAdmin=true')" `
	}
}

task uninstall stop, {
	servy-cli uninstall -n $ServiceName
}

task start {
	servy-cli start -n $ServiceName
}

task stop {
	servy-cli stop -n $ServiceName
}

task restart stop, start

# Synopsis: Use on changing code or packages.
task rebuild stop, publish, start

# Synopsis: Use on changing service options.
task reinstall stop, uninstall, publish, install, start

task . run
