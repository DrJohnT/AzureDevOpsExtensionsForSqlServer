[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Processes a tabular cube database

	.DESCRIPTION
    Processes a tabular cube database on a SQL Server Analysis Services (SSAS) server

    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    Depends on PowerShell module DeployCube written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
#>
    [string]$AsServer = Get-VstsInput -Name AsServer -Require;
    [string]$CubeDatabaseName = Get-VstsInput -Name CubeDatabaseName;
    [string]$RefreshType = Get-VstsInput -Name RefreshType;

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    Write-Host "AsServer:           $AsServer";
    Write-Host "CubeDatabaseName:   $CubeDatabaseName";
    Write-Host "RefreshType:        $RefreshType";

    Write-Host "==============================================================================";

    try {
        Invoke-ProcessSsasDatabase -Server $AsServer -CubeDatabase $CubeDatabaseName -RefreshType $RefreshType;
    } finally {
        Write-Host "==============================================================================";
        Trace-VstsLeavingInvocation $MyInvocation
    }


