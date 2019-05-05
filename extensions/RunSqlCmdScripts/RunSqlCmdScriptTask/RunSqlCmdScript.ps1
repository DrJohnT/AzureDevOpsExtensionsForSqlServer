[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Run a single SQL Script in SQLCMD mode, passing in an array of SQLCMD variables

    .DESCRIPTION
    Run a single SQL Script in SQLCMD mode, passing in an array of SQLCMD variables.

    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    .NOTES
    Depends on PowerShell module SqlServer which it will install for the current user
#>

    # ensure SqlServer module is installed
    if (!(Get-Module -ListAvailable -Name SqlServer)) {
        # if module is not installed
        Write-Output "Installing PowerShell module SqlServer for current user"
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser;
        Install-Module -Name SqlServer -Force -AllowClobber -Scope CurrentUser -Repository PSGallery -SkipPublisherCheck;
    }
    if (-not (Get-Module -Name SqlServer)) {
        # if module is not loaded
        Import-Module -Name SqlServer -DisableNameChecking;
    }

    [string]$SqlCmdSciptPath = Get-VstsInput -Name "SqlCmdSciptPath" -Require;
    [string]$Server = Get-VstsInput -Name  "Server" -Require;
    [string]$Database = Get-VstsInput -Name "Database" -Require;
    [string]$SqlCmdVariables = Get-VstsInput -Name "SqlCmdVariables";

    if (!([string]::IsNullOrEmpty($SqlCmdVariables))) {
        [string[]]$SqlCmdArray = $SqlCmdVariables -split "`n" | ForEach-Object { $_.trim() }
    }


    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    Write-Host "Calling Invoke-SqlCmd with the following parameters:";
    Write-Host "SqlCmdSciptPath:   $SqlCmdSciptPath";
    Write-Host "Server:            $Server";
    Write-Host "Database:          $Database";

    if (!([string]::IsNullOrEmpty($SqlCmdVariables))) {
        #Write-Host $SqlCmdArray.GetType();
        foreach ($SqlCmdVariable in $SqlCmdArray) {
            Write-Host "SqlCmdVariable:    $SqlCmdVariable"
        }
    }

    Write-Host "==============================================================================";

    try {
        if ([string]::IsNullOrEmpty($SqlCmdVariables)) {
            Invoke-Sqlcmd -Server $Server -Database $Database -InputFile $SqlCmdSciptPath;
        } else {
            Invoke-Sqlcmd -Server $Server -Database $Database -InputFile $SqlCmdSciptPath -Variable $SqlCmdArray;
        }
    } finally {
        Write-Host "==============================================================================";
        Trace-VstsLeavingInvocation $MyInvocation
    }




