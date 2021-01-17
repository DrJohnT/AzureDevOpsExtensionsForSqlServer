[CmdletBinding()]
param()

<#
	.SYNOPSIS
    Publishes a SQL Server Database DacPac using a DacPac publish profile

	.DESCRIPTION
    Publishes a SSDT DacPac using a specified DAC publish profile from your solution.
    Basically deploys the DACPAC by invoking SqlPackage.exe using a DacPac Publish profile

    Script written by (c) Dr. John Tunnicliffe, 2019-2021 for Azure DevOps extension PublishDacPac available here: https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.PublishDacPac
    Source code and documentation: https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/PublishDacPac
	This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    Depends on PowerShell module PublishDacPac written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
#>

    # import required modules
    $ModulePath = Split-Path -Parent $MyInvocation.MyCommand.Path;
	$ModulePath = Resolve-Path "$ModulePath\ps_modules\PublishDacPac\PublishDacPac.psd1";
    import-Module -Name $ModulePath;

    [string]$DacPacPath = Get-VstsInput -Name "DacPacPath" -Require;
    [string]$DacPublishProfile = Get-VstsInput -Name "DacPublishProfile" -Require;
    [string]$TargetServerName = Get-VstsInput -Name  "TargetServerName" -Require;
    [string]$TargetDatabaseName = Get-VstsInput -Name "TargetDatabaseName";
    [string]$SqlCmdVariableType = Get-VstsInput -Name "SqlCmdVariableType";
    [string]$SqlCmdVariablesInJson = Get-VstsInput -Name "SqlCmdVariablesInJson";
    [string]$SqlCmdVariablesInText = Get-VstsInput -Name "SqlCmdVariablesInText";
    [string]$PreferredVersion = Get-VstsInput -Name "PreferredVersion";
    [string]$AuthenticationMethod = Get-VstsInput -Name "AuthenticationMethod";
    [string]$AuthenticationUser = Get-VstsInput -Name "AuthenticationUser";
    [string]$AuthenticationPassword = Get-VstsInput -Name "AuthenticationPassword";
    [string]$EncryptConnection = Get-VstsInput -Name "EncryptConnection";

    $global:ErrorActionPreference = 'Stop';

    Trace-VstsEnteringInvocation $MyInvocation;

    Write-Host "Invoking Publish-DacPac (https://github.com/DrJohnT/PublishDacPac) with the following parameters:";
    Write-Host "DacPacPath:         $DacPacPath";
    Write-Host "DacPublishProfile:  $DacPublishProfile";
    Write-Host "TargetServerName:   $TargetServerName";
    Write-Host "TargetDatabaseName: $TargetDatabaseName";
    Write-Host "PreferredVersion:   $PreferredVersion";
    Write-Host "SqlCmdVariableType: $SqlCmdVariableType";
    if ($AuthenticationMethod -eq "sqlauth") {
        Write-Host "SQL Auth User:      $AuthenticationUser";
    }

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
            #Write-Host     $SqlCmdVariablesInText
            $SqlCmdVariables = $SqlCmdVariablesInText -split "`n" | ForEach-Object { $_.trim() }
        }
    }

    if ($SqlCmdVariableType -ne 'none') {
        Write-Host "SqlCmdVariables:";
        foreach ($SqlCmdVariable in $SqlCmdVariables) {
            Write-Host "                    $SqlCmdVariable";
        }
    }

    Write-Host "==============================================================================";

    try {
        $Command = "Publish-DacPac -DacPacPath '$DacPacPath' -DacPublishProfile '$DacPublishProfile' -Server '$TargetServerName' -Database '$TargetDatabaseName' -PreferredVersion '$PreferredVersion'";
        if ($AuthenticationMethod -eq "sqlauth") { 
            $Command += " -Username '$AuthenticationUser' -Password '$AuthenticationPassword'";
        }        
        if ($EncryptConnection -eq "true") {
            $Command += " -EncryptConnection $true";
        }
        if ("$DeployScriptPath" -ne "") {
            $Command += " -DeployScriptPath '$DeployScriptPath'";
        }
        if ("$DeployReportPath" -ne "") {
            $Command += " -DeployReportPath '$DeployReportPath'";
        }        
        if ($SqlCmdVariableType -ne 'none') {
            $Command += ' -SqlCmdVariables $SqlCmdVariables';
            $scriptBlock = [Scriptblock]::Create($Command);
            Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $SqlCmdVariables;
        } else {                     
            $scriptBlock = [Scriptblock]::Create($Command);
            Invoke-Command -ScriptBlock $scriptBlock;
        }
    } finally {
        Write-Host "==============================================================================";
        Trace-VstsLeavingInvocation $MyInvocation
    }




