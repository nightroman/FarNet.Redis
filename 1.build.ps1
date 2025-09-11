<#
.Synopsis
	Build script, https://github.com/nightroman/Invoke-Build
#>

param(
	$Configuration = (property Configuration Release),
	$FarHome = (property FarHome C:\Bin\Far\x64)
)

$ProgressPreference = 0
Set-StrictMode -Version 3
$ModuleName = 'FarNet.Redis'
$ModuleRoot = "$FarHome\FarNet\Lib\$ModuleName"
$Description = 'StackExchange.Redis PowerShell module and FarNet library'

function __clean {
	Push-Location $PSScriptRoot
	remove README.html, *.nupkg, z, src\*\bin, src\*\obj, src\TestResults
	Pop-Location
}

task clean {
	__clean
}

task build meta, {
	Set-Location src\PS.FarNet.Redis
	exec { dotnet build -c $Configuration }
}

task publish {
	Set-Location src

	exec { dotnet publish PS.FarNet.Redis/PS.FarNet.Redis.csproj -c $Configuration -o $ModuleRoot --no-build }
	remove $ModuleRoot\PS.FarNet.Redis.deps.json, $ModuleRoot\System.Management.Automation.dll

	$v1 = (Select-Xml '//PackageReference[@Include="StackExchange.Redis"]' FarNet.Redis\FarNet.Redis.csproj).Node.Version
	Copy-Item -Destination $ModuleRoot @(
		"$HOME\.nuget\packages\StackExchange.Redis\$v1\lib\net6.0\StackExchange.Redis.xml"
	)
}

task content -After publish {
	exec { robocopy src\Content $ModuleRoot } (0..3)
}

task version {
	($Script:Version = Get-BuildVersion Release-Notes.md '##\s+v(\d+\.\d+\.\d+)')
}

task help {
	. Helps.ps1
	Convert-Helps Help.ps1 $ModuleRoot\PS.FarNet.Redis.dll-Help.xml
}

task markdown version, {
	requires -Path $env:MarkdownCss
	exec { pandoc.exe @(
		'README.md'
		'--output=README.html'
		'--from=gfm'
		'--embed-resources'
		'--standalone'
		"--css=$env:MarkdownCss"
		"--metadata=pagetitle=$ModuleName $Version"
	)}
}

task meta -Inputs 1.build.ps1, Release-Notes.md -Outputs src\Directory.Build.props -Jobs version, {
	Set-Content src\Directory.Build.props @"
<Project>
	<PropertyGroup>
		<Company>https://github.com/nightroman/$ModuleName</Company>
		<Copyright>Copyright (c) Roman Kuzmin</Copyright>
		<Description>$Description</Description>
		<Product>$ModuleName</Product>
		<Version>$Version</Version>
		<IncludeSourceRevisionInInformationalVersion>False</IncludeSourceRevisionInInformationalVersion>
	</PropertyGroup>
</Project>
"@
}

task package help, markdown, version, {
	remove z
	$Script:PSPackageRoot = mkdir "z\tools\FarHome\FarNet\Lib\$ModuleName"

	exec { robocopy $ModuleRoot $PSPackageRoot /s /xf *.pdb } 1

	Copy-Item -Destination z @(
		'README.md'
	)

	Copy-Item -Destination $PSPackageRoot @(
		"README.html"
		"LICENSE"
	)

	Import-Module PsdKit
	$xml = Import-PsdXml $PSPackageRoot\$ModuleName.psd1
	Set-Psd $xml $Version 'Data/Table/Item[@Key="ModuleVersion"]'
	Export-PsdXml $PSPackageRoot\$ModuleName.psd1 $xml

	Assert-SameFile.ps1 -Result (Get-ChildItem $PSPackageRoot -Recurse -File -Name) -Text -View $env:MERGE @'
about_FarNet.Redis.help.txt
FarNet.Redis.dll
FarNet.Redis.ini
FarNet.Redis.psd1
LICENSE
Microsoft.Extensions.DependencyInjection.Abstractions.dll
Microsoft.Extensions.Logging.Abstractions.dll
Pipelines.Sockets.Unofficial.dll
PS.FarNet.Redis.dll
PS.FarNet.Redis.dll-Help.xml
README.html
StackExchange.Redis.dll
StackExchange.Redis.xml
System.IO.Pipelines.dll
'@
}

task nuget package, version, {
	equals $Version (Get-Item "$ModuleRoot\$ModuleName.dll").VersionInfo.ProductVersion

	Set-Content z\Package.nuspec @"
<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
	<metadata>
		<id>$ModuleName</id>
		<version>$Version</version>
		<authors>Roman Kuzmin</authors>
		<owners>Roman Kuzmin</owners>
		<license type="expression">MIT</license>
		<readme>README.md</readme>
		<projectUrl>https://github.com/nightroman/$ModuleName</projectUrl>
		<description>$Description</description>
		<releaseNotes>https://github.com/nightroman/$ModuleName/blob/main/Release-Notes.md</releaseNotes>
		<tags>FarManager FarNet Redis Client Database</tags>
	</metadata>
</package>
"@

	exec { NuGet.exe pack z\Package.nuspec }
}

task pushNuGet nuget, version, {
	$NuGetApiKey = Read-Host NuGetApiKey
	exec { nuget push "$ModuleName.$Version.nupkg" -Source nuget.org -ApiKey $NuGetApiKey }
}

task pushPSGallery package, {
	$NuGetApiKey = Read-Host NuGetApiKey
	Publish-Module -Path $PSPackageRoot -NuGetApiKey $NuGetApiKey
}

task testUnit {
	Set-Location src\FarNet.Redis.Tests
	exec { dotnet run -c Release }
	__clean
}

task testStar {
	Invoke-Build ** tests
}

task test testUnit, testStar

task release pushNuGet, pushPSGallery, clean

task . build, clean
