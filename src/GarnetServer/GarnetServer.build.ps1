
Set-StrictMode -Version 3

$ServiceName = 'garnet'
$ServiceRoot = 'C:\Bin\GarnetServer'
$ServiceApp = "$ServiceRoot\GarnetServer.exe"
$DataRoot = 'C:\DATA\Garnet'
$LogFile = "$DataRoot\service.log"
$ArgList = @(
	'-q --recover --logger-level Information'
	"--checkpointdir $DataRoot"
	'--index 512m'
	'--obj-index 64m'
) -join ' '

task run {
	Start-Process $ServiceRoot\GarnetServer.exe $ArgList
}

task publish {
	remove $ServiceRoot
	exec { dotnet publish -c Release -o $ServiceRoot }
	remove bin, obj
}

task install {
	exec { nssm install $ServiceName $ServiceApp $ArgList }
	exec { nssm set $ServiceName AppStdout $LogFile }
	exec { nssm set $ServiceName AppStderr $LogFile }
}

task start {
	nssm start $ServiceName
}

task stop {
	nssm stop $ServiceName
}

task uninstall stop, {
	nssm remove $ServiceName confirm
}

task . run
