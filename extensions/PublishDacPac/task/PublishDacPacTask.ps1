[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Publishes a SQL Server SSDT DacPac using a DacPac publish profile

	.DESCRIPTION
    Publishes a SSDT DacPac using a specified DacPac publish profile from your solution.
    Basically deploys the DACPAC by invoking SqlPackage.exe using a template DacPac Publish profile

	Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

#>
    # import required modules
    $BootStrapPath = Join-Path -Path $PSScriptRoot -ChildPath '.\bootstrap.ps1' -Resolve;

    . $BootStrapPath;

    $DacPacPath = Get-VstsInput -Name "DacPacPath" -Require;
    $DacPublishProfile = Get-VstsInput -Name "DacPublishProfile" -Require;
    $TargetServerName = Get-VstsInput -Name  "TargetServerName" -Require;
    $TargetDatabaseName = Get-VstsInput -Name "TargetDatabaseName";
    $PreferredVersion = Get-VstsInput -Name "PreferredVersion";

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation
    try {
        #Set-VstsTaskVariable -Name "System.Culture" -Value "en-US";

        #Import-VstsLocStrings "$PSScriptRoot\Task.json";

		#[bool]$debug = Get-VstsTaskVariable -Name System.Debug -AsBool -Default true;
		if ($TargetDatabaseName -is $null) {
			Publish-DacPac -DacPacPath $DacPacPath -DacPublishProfile $DacPublishProfile -TargetServerName $TargetServerName -PreferredVersion $PreferredVersion;
		} else {
			Publish-DacPac -DacPacPath $DacPacPath -DacPublishProfile $DacPublishProfile -TargetServerName $TargetServerName -TargetDatabaseName $TargetDatabaseName -PreferredVersion $PreferredVersion;
		}
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }


