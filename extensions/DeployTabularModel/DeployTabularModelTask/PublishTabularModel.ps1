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

    Depends on PowerShell module DeployCube written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
#>

    if (-not (Get-Module -Name "DeployCube")) {
        # if module is not loaded
        $ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path;
        $ModulePath = Resolve-Path "$ModulePath\ps_modules\DeployCube\DeployCube.psd1";
        import-Module -Name $ModulePath;
    }

    [string]$AsDatabasePath = Get-VstsInput -Name "AsDatabasePath" -Require;
    [string]$AsServer = Get-VstsInput -Name  "AsServer" -Require;
    [string]$CubeDatabaseName = Get-VstsInput -Name "CubeDatabaseName";
    [string]$PreferredVersion = Get-VstsInput -Name "PreferredVersion";

    [string]$TransactionalDeploymentStr = Get-VstsInput -Name "TransactionalDeployment";
    [string]$PartitionDeployment = Get-VstsInput -Name "PartitionDeployment";
    [string]$RoleDeployment = Get-VstsInput -Name "RoleDeployment";
    [string]$ConfigurationSettingsDeployment = Get-VstsInput -Name "ConfigurationSettingsDeployment";
    [string]$OptimizationSettingsDeployment = Get-VstsInput -Name "OptimizationSettingsDeployment";
    [string]$UserID = Get-VstsInput -Name "UserID";
    [string]$Password = Get-VstsInput -Name "Password";

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    Write-Host "Invoking Publish-Cube from [DeployCube](https://github.com/DrJohnT/DeployCube) module with the following parameters:";
    Write-Host "AsDatabasePath:     $AsDatabasePath";
    Write-Host "AsServer:           $AsServer";
    Write-Host "CubeDatabaseName:   $CubeDatabaseName"
    Write-Host "PreferredVersion:   $PreferredVersion"
    if ("$UserID" -ne "") {
        Write-Host "UserID:             $UserID";
    }

    Write-Host "==============================================================================";

    try {
        [bool]$TransactionalDeployment = $false;
        if($TransactionalDeploymentStr -eq "true") { $TransactionalDeployment = $true } 

        Publish-Cube -AsDatabasePath "$AsDatabasePath" -Server "$AsServer" -CubeDatabase "$CubeDatabaseName" -PreferredVersion $PreferredVersion `
            -TransactionalDeployment $TransactionalDeployment -PartitionDeployment $PartitionDeployment -RoleDeployment $RoleDeployment `
            -ConfigurationSettingsDeployment $ConfigurationSettingsDeployment -OptimizationSettingsDeployment $OptimizationSettingsDeployment `
            -UserID "$UserID" -Password "$Password";
    } finally {
        Write-Host "==============================================================================";
        Trace-VstsLeavingInvocation $MyInvocation
    }




