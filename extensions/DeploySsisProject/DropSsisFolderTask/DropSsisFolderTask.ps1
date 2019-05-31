[CmdletBinding()]
param()
<#
	.SYNOPSIS
    Create a SSIS folder if it does not exist and update the folder's description.

    .DESCRIPTION
    Create a SSIS folder if it does not exist and update the folder's description.

    .NOTES
    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/DeploySsisProject
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [string]$Folder = Get-VstsInput -Name Folder -Require;
    [string]$Server = Get-VstsInput -Name Server -Require;
    [string]$Database = Get-VstsInput -Name Database -Require;

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    try {
        $CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
        $SqlCmdSciptPath = Resolve-Path "$CurrentFolder\DropSsisFolder.sql";

        $SqlCmdVariables = @();
        $SqlCmdVariables += "SsisFolder=$Folder";
        $SqlCmdVariables += "SSISDB=$Database";
        $QueryTimeout = 10;

        if ($env:Processor_Architecture -eq 'x86') {
            Write-Error "The SQLSERVER PowerShell module will not run correctly in when the processor architecture = x86. Please use a 64-bit Azure DevOps agent. See https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops";
            exit 1;
        }

        Write-Host "==============================================================================";
        Write-Host "Calling Invoke-SqlCmd with the following parameters:";
        Write-Host "Server:                  $Server";
        Write-Host "SSIS Database:           $Database";
        Write-Host "SSIS Folder              $Folder";

        # ensure SqlServer module is installed
        $Name = 'SqlServer';
        if (!(Get-Module -ListAvailable -Name $Name)) {
            # if module is not installed
            Write-Output "Installing PowerShell module $Name for current user"
            Install-PackageProvider -Name NuGet -Force -Scope CurrentUser;
            Install-Module -Name $Name -Force -AllowClobber -Scope CurrentUser -Repository PSGallery -SkipPublisherCheck;
        }

        if (-not (Get-Module -Name $Name)) {
            # if module is not loaded
            Import-Module -Name $Name -DisableNameChecking;
        }

        # Now Invoke-Sqlcmd
        Invoke-Sqlcmd -Server $Server -Database $Database -InputFile $SqlCmdSciptPath -QueryTimeout $QueryTimeout -ErrorAction Stop -Variable $SqlCmdVariables;
        Write-Host "==============================================================================";
    } catch {
        Write-Error $_;
        exit 1;
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }






