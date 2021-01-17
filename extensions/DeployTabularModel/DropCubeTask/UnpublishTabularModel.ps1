[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Drops a cube from an SQL Server Analysis Services server

	.DESCRIPTION
    Deletes a cube database from an SQL Server Analysis Services server

    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    Depends on PowerShell module DeployCube written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
#>
    if (-not (Get-Module -Name "DeployCube")) {
        # if module is not loaded
        $ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path;
        $ModulePath = Resolve-Path "$ModulePath\ps_modules\DeployCube\DeployCube.psd1";
        Import-Module -Name $ModulePath;
    }

    [string]$AsServer = Get-VstsInput -Name  "AsServer" -Require;
    [string]$CubeDatabaseName = Get-VstsInput -Name "CubeDatabaseName" -Require;
    [string]$AuthenticationUser = Get-VstsInput -Name AuthenticationUser;
    [string]$AuthenticationPassword = Get-VstsInput -Name AuthenticationPassword;

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    Write-Host "Invoking Unpublish-Cube from [DeployCube](https://github.com/DrJohnT/DeployCube) module with the following parameters:";
    Write-Host "AsServer:           $AsServer";
    Write-Host "CubeDatabaseName:   $CubeDatabaseName";
    if ("$AuthenticationUser" -ne "") {
        Write-Host "AuthenticationUser: $AuthenticationUser";
    }    

    Write-Host "==============================================================================";

    try {
        if ("" -eq "$AuthenticationPassword") {
            if ( Ping-SsasDatabase -Server "$AsServer" -CubeDatabase "$CubeDatabaseName" ) {
                Unpublish-Cube -Server "$AsServer" -CubeDatabase "$CubeDatabaseName";
            }
       } else {
           [SecureString] $SecurePassword = ConvertTo-SecureString $AuthenticationPassword -AsPlainText -Force;
           [PsCredential] $Credential = New-Object System.Management.Automation.PSCredential($AuthenticationUser, $SecurePassword);
           if ( Ping-SsasDatabase -Server "$AsServer" -CubeDatabase "$CubeDatabaseName" -Credential $Credential) {
               Unpublish-Cube -Server "$AsServer" -CubeDatabase "$CubeDatabaseName" -Credential $Credential;
           }
       }
    } finally {
        Write-Host "==============================================================================";
        Trace-VstsLeavingInvocation $MyInvocation
    }


