[CmdletBinding()]
param()
<#
	.SYNOPSIS
    Run all SQL Scripts in folder in SQLCMD mode, passing in an array of SQLCMD variables if supplied.

    .DESCRIPTION
    Run all SQL Scripts in folder in SQLCMD mode, passing in an array of SQLCMD variables if supplied.

    .NOTES
    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/RunSqlCmdScripts
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [string]$SqlCmdSciptFolderPath = Get-VstsInput -Name SqlCmdSciptFolderPath -Require;
    [string]$Server = Get-VstsInput -Name  Server -Require;
    [string]$Database = Get-VstsInput -Name Database -Require;
    [string]$SqlCmdVariableType = Get-VstsInput -Name SqlCmdVariableType;
    [string]$SqlCmdVariablesInJson = Get-VstsInput -Name SqlCmdVariablesInJson;
    [string]$SqlCmdVariablesInText = Get-VstsInput -Name SqlCmdVariablesInText;
    [string]$QueryTimeout = Get-VstsInput -Name QueryTimeout;
    [string]$Recursive = Get-VstsInput -Name Recursive;

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    try {
        if (Test-Path -Path $SqlCmdSciptFolderPath)
        {
            $CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
            $Script = Resolve-Path "$CurrentFolder\Invoke-SqlCmdScriptsInFolder.ps1";

            ########################################################################################################
            # If PowerShell is running in 32-bit mode on a 64-bit machine, we need to force PowerShell to run in
            # 64-bit mode to allow the SqlServer module to function correctly.
            ########################################################################################################
            if ($env:Processor_Architecture -eq 'x86') {
                write-host "Invoking script in x64 PowerShell: $Script";
                &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -File $Script -Server $Server -Database $Database -SqlCmdSciptFolderPath $SqlCmdSciptFolderPath `
                    -SqlCmdVariableType $SqlCmdVariableType -SqlCmdVariablesInJson $SqlCmdVariablesInJson -SqlCmdVariablesInText $SqlCmdVariablesInText -QueryTimeout $QueryTimeout -Recursive $Recursive;
                exit $lastexitcode;
            } else {
                &$Script -Server $Server -Database $Database -SqlCmdSciptFolderPath $SqlCmdSciptFolderPath `
                    -SqlCmdVariableType $SqlCmdVariableType -SqlCmdVariablesInJson $SqlCmdVariablesInJson -SqlCmdVariablesInText $SqlCmdVariablesInText -QueryTimeout $QueryTimeout -Recursive $Recursive;
            }
        } else {
            Write-Error "SQL Scripts Folder does not exist: $SqlCmdSciptFolderPath";
        }
    } catch {
        Write-Error $_;
        exit 1;
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }




