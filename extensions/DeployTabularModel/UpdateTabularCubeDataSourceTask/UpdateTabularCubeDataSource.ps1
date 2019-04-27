[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Updates the data source for a deployed tabular cube instance

	.DESCRIPTION
    Updates the connection string for the deployed tabular cube

    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    Depends on PowerShell module DeployCube written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
#>

    if (-not (Get-Module -Name "DeployCube")) {
        # if module is not loaded
        $ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path;
        $ModulePath = Resolve-Path "$ModulePath\ps_modules\DeployCube\DeployCube.psd1";
        import-Module -Name $ModulePath;
    }

    [string]$AsServer = Get-VstsInput -Name  AsServer -Require;
    [string]$CubeDatabaseName = Get-VstsInput -Name CubeDatabaseName;
    [string]$SourceSqlServer =  Get-VstsInput -Name SourceSqlServer;
    [string]$SourceSqlDatabase =  Get-VstsInput -Name SourceSqlDatabase;
    [string]$ImpersonationMode =  Get-VstsInput -Name ImpersonationMode;
    [string]$ImpersonationAccount =  Get-VstsInput -Name ImpersonationAccount;
    [string]$ImpersonationPassword =  Get-VstsInput -Name ImpersonationPassword;

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    Write-Host "Invoking Update-CubeDataSource from [DeployCube](https://github.com/DrJohnT/DeployCube) module with the following parameters:";
    Write-Host "AsServer:             $AsServer";
    Write-Host "CubeDatabaseName:     $CubeDatabaseName"
    Write-Host "SourceSqlServer:      $SourceSqlServer"
    Write-Host "SourceSqlDatabase:    $SourceSqlDatabase"
    Write-Host "ImpersonationMode:    $ImpersonationMode"
    Write-Host "ImpersonationAccount: $ImpersonationAccount"
    Write-Host "==============================================================================";

    try {
        if ( Ping-SsasDatabase -Server $AsServer -CubeDatabase $CubeDatabaseName ) {
            if ([string]::IsNullOrEmpty($ImpersonationAccount)) {
                Update-CubeDataSource -Server $AsServer -CubeDatabase $CubeDatabaseName -SourceSqlServer $SourceSqlServer -SourceSqlDatabase $SourceSqlDatabase -ImpersonationMode $ImpersonationMode;
            } else {
                Update-CubeDataSource -Server $AsServer -CubeDatabase $CubeDatabaseName -SourceSqlServer $SourceSqlServer -SourceSqlDatabase $SourceSqlDatabase -ImpersonationMode $ImpersonationMode -ImpersonationAccount $ImpersonationAccount -ImpersonationPassword $ImpersonationPassword;
            }
        }
    } finally {
        Write-Host "==============================================================================";
        Trace-VstsLeavingInvocation $MyInvocation
    }


