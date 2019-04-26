[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Publishes a SQL Server SSAS Tabular Model (AsDatabase file) using Microsoft.AnalysisServices.Deployment.exe

	.DESCRIPTION
    Publishes a AsDatabase file built by your solution.
    Basically deploys the AsDatabase by invoking Microsoft.AnalysisServices.Deployment.exe

    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    Depends on PowerShell module PublishDacPac written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
#>

    $ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path;
    $ModulePath = Resolve-Path "$ModulePath\ps_modules\DeployCube\DeployCube.psd1";
    import-Module -Name $ModulePath;

    Write-Host "Reading inputs";

    [string]$AsDatabasePath = Get-VstsInput -Name "AsDatabasePath" -Require;
    [string]$AsServer = Get-VstsInput -Name  "AsServer" -Require;
    [string]$CubeDatabaseName = Get-VstsInput -Name "CubeDatabaseName";
    [string]$PreferredVersion = Get-VstsInput -Name "PreferredVersion";
    [string]$ProcessingOption = Get-VstsInput -Name "ProcessingOption";

    [string]$TransactionalDeployment = Get-VstsInput -Name "TransactionalDeployment";
    [string]$PartitionDeployment = Get-VstsInput -Name "PartitionDeployment";
    [string]$RoleDeployment = Get-VstsInput -Name "RoleDeployment";
    [string]$ConfigurationSettingsDeployment = Get-VstsInput -Name "ConfigurationSettingsDeployment";
    [string]$OptimizationSettingsDeployment = Get-VstsInput -Name "OptimizationSettingsDeployment";

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    Write-Host "Invoking Publish-Cube (https://github.com/DrJohnT/DeployCube) with the following parameters:";
    Write-Host "AsDatabasePath:     $AsDatabasePath";
    Write-Host "AsServer:           $AsServer";
    Write-Host "CubeDatabaseName:   $CubeDatabaseName"
    Write-Host "PreferredVersion:   $PreferredVersion"

    Write-Host "==============================================================================";

    try {
        Publish-Cube -AsDatabasePath $AsDatabasePath -Server $AsServer -CubeDatabase $CubeDatabaseName -PreferredVersion $PreferredVersion -ProcessingOption $ProcessingOption `
            -TransactionalDeployment $TransactionalDeployment -PartitionDeployment $PartitionDeployment -RoleDeployment $RoleDeployment `
            -ConfigurationSettingsDeployment $ConfigurationSettingsDeployment -OptimizationSettingsDeployment $OptimizationSettingsDeployment;
    } finally {
        Write-Host "==============================================================================";
        Trace-VstsLeavingInvocation $MyInvocation
    }




