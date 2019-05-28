[CmdletBinding()]
param()
<#
	.SYNOPSIS
    Run a single SQL Script in SQLCMD mode, passing in an array of SQLCMD variables if supplied.

    .DESCRIPTION
    Run a single SQL Script in SQLCMD mode, passing in an array of SQLCMD variables if supplied.

    .NOTES
    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/RunSqlCmdScripts
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [string]$SqlCmdSciptPath = Get-VstsInput -Name SqlCmdSciptPath -Require;
    [string]$Server = Get-VstsInput -Name  Server -Require;
    [string]$Database = Get-VstsInput -Name Database -Require;
    [string]$SqlCmdVariableType = Get-VstsInput -Name SqlCmdVariableType;
    [string]$SqlCmdVariablesInJson = Get-VstsInput -Name SqlCmdVariablesInJson;
    [string]$SqlCmdVariablesInText = Get-VstsInput -Name SqlCmdVariablesInText;
    [string]$QueryTimeout = Get-VstsInput -Name QueryTimeout;

    $global:ErrorActionPreference = 'Stop';

    if ($env:Processor_Architecture -eq 'x86') {
        Write-Error "The SQLSERVER PowerShell module will not run correctly in when the processor architecture = x86. Please use a 64-bit Azure DevOps agent. See https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops";
        exit 1;
    }

    Trace-VstsEnteringInvocation $MyInvocation;

    try {
        Write-Host "==============================================================================";
        Write-Host "Calling Invoke-SqlCmd with the following parameters:";
        Write-Host "Server:             $Server";
        Write-Host "Database:           $Database";
        Write-Host "SqlCmdSciptPath:    $SqlCmdSciptPath";
        Write-Host "SqlCmdVariableType: $SqlCmdVariableType";

        [string[]]$SqlCmdVariables = @();
        switch ($SqlCmdVariableType) {
            'json' {
                $jsonVariables = ConvertFrom-Json -InputObject $SqlCmdVariablesInJson;
                $jsonVariables.PSObject.Properties | ForEach-Object {
                    $Name = $_.Name;
                    $Value = $_.Value;
                    $SqlCmdVariables += "$Name=$Value";
                }
            }
            'text' {
                $SqlCmdVariables = $SqlCmdVariablesInText -split "`n" | ForEach-Object { $_.trim() }
            }
        }

        if ($SqlCmdVariableType -ne 'none') {
            Write-Host "SqlCmdVariables:";
            foreach ($SqlCmdVariable in $SqlCmdVariables) {
                Write-Host "                    $SqlCmdVariable";
            }
        }

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
        if ($SqlCmdVariableType -eq 'none') {
            Invoke-Sqlcmd -Server $Server -Database $Database -InputFile $SqlCmdSciptPath -QueryTimeout $QueryTimeout -ErrorAction Stop;
        } else {
            Invoke-Sqlcmd -Server $Server -Database $Database -InputFile $SqlCmdSciptPath -QueryTimeout $QueryTimeout -ErrorAction Stop -Variable $SqlCmdVariables;
        }
        Write-Host "==============================================================================";
    } catch {
        Write-Error $_;
        exit 1;
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }




