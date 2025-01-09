<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build

.Description
	Tasks to build and maintain the service "garnet".
	Requires: https://github.com/kirillkovalenko/nssm
#>

$Port = 3278
$Service = 'garnet'
$AppRoot = 'C:\Bin\Garnet'
$DataRoot = 'C:\Data\Garnet'
$Log = "$DataRoot\service.log"
$App = "$AppRoot\GarnetServer.exe"
$Arg = @(
	'--port', $Port
	'--checkpointdir', "$DataRoot\checkpointdir"
	'--index', '128m'
	'--obj-index', '16m'
	'--lua'
	'--lua-transaction-mode'
	'-q'
	'--recover'
	'--logger-level', 'Information'
) -join ' '

task run {
	Start-Process $App $Arg
}

task publish {
	remove $AppRoot
	exec { dotnet publish --use-current-runtime -c Release -o $AppRoot }
	remove bin, obj
}

task install {
	# install the service
	exec { nssm install $Service $App $Arg }

	# send standard and error output to file
	exec { nssm set $Service AppStdout $Log }
	exec { nssm set $Service AppStderr $Log }

	# let required network services start first
	exec { nssm set $Service Start SERVICE_DELAYED_AUTO_START }

	# https://github.com/microsoft/garnet/issues/902
	exec { nssm set $Service AppEnvironmentExtra "DOTNET_LegacyExceptionHandling=1" }

	# save before stopping, using FarNet.Redis all users module
	$pwsh = (Get-Command pwsh.exe).Definition
	exec { nssm set $Service AppEvents Stop/Pre "$pwsh -c Import-Module FarNet.Redis; Save-Redis 127.0.0.1:$Port" }
}

task start {
	nssm start $Service
}

task stop {
	nssm stop $Service
}

task uninstall stop, {
	nssm remove $Service confirm
}

# Synopsis: Use on changing code.
task rebuild stop, publish, start

# Synopsis: Use on changing options.
task reinstall stop, uninstall, publish, install, start

task . run
