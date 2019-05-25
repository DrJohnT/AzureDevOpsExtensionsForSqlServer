[CmdletBinding()]
param()
<#
	.SYNOPSIS
    Create a SSIS folder if it does not exist and update the folder's description.

    .DESCRIPTION
    Create a SSIS folder if it does not exist and update the folder's description.

    Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    .NOTES
    Depends on PowerShell module SqlServer which it will install for the current user.
#>
    [string]$Folder = Get-VstsInput -Name Folder -Require;
    [string]$FolderDescription = Get-VstsInput -Name FolderDescription -Require;
    [string]$Server = Get-VstsInput -Name Server -Require;
    [string]$Database = Get-VstsInput -Name Database -Require;

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    try {
        $CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
        $Script = Resolve-Path "$CurrentFolder\Invoke-SqlCmdScript.ps1";
        $SqlCmdSciptPath = Resolve-Path "$CurrentFolder\CreateSsisFolder.sql";

        $SqlCmdVariableType = 'text';
        $SqlCmdVariablesInJson=$null;
        $SqlCmdVariablesInText = @"
SsisFolder=$Folder
SsisFolderDescription=$FolderDescription
"@;
        $QueryTimeout = 10;

        ########################################################################################################
        # If PowerShell is running in 32-bit mode on a 64-bit machine, we need to force PowerShell to run in
        # 64-bit mode to allow the SqlServer module to function correctly.
        ########################################################################################################
        if ($env:Processor_Architecture -eq 'x86') {
            write-host "Invoking script in x64 PowerShell: $Script";
            &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -File $Script -Server $Server -Database $Database -SqlCmdSciptPath $SqlCmdSciptPath `
                -SqlCmdVariableType $SqlCmdVariableType -SqlCmdVariablesInJson $SqlCmdVariablesInJson -SqlCmdVariablesInText $SqlCmdVariablesInText -QueryTimeout $QueryTimeout;
            exit $lastexitcode;
        } else {
            &$Script -Server $Server -Database $Database -SqlCmdSciptPath $SqlCmdSciptPath `
                -SqlCmdVariableType $SqlCmdVariableType -SqlCmdVariablesInJson $SqlCmdVariablesInJson -SqlCmdVariablesInText $SqlCmdVariablesInText -QueryTimeout $QueryTimeout;
        }
    } catch {
        Write-Error $_;
        exit 1;
    } finally {
        Trace-VstsLeavingInvocation $MyInvocation
    }




