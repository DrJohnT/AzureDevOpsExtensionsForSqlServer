# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
#Write-host $CurrentFolder
$mediaFolder =  Resolve-Path "$CurrentFolder\..\..\..\examples";
#Write-host $mediaFolder
$DacPac = "DatabaseToPublish.dacpac";
$DacPacFolder = Resolve-Path "$mediaFolder\DatabaseToPublish\bin\Debug";
$DacPacPath = Resolve-Path "$DacPacFolder\$DacPac";
$DacProfile = "DatabaseToPublish.CI.publish.xml";
#$DacProfilePath = Resolve-Path "$DacPacFolder\$DacProfile";
$AltDacProfilePath = Resolve-Path "$mediaFolder\DatabaseToPublish\DatabaseToPublish.LOCAL.publish.xml";
#Write-host $AltDacProfilePath

$psModules =  Resolve-Path "$CurrentFolder\..\PublishDacPacTask\ps_modules";
#Write-host $psModules
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }
#Import-Module "$psModules\VstsTaskSdk";
#Import-Module "$psModules\PublishDacPac";

$PublishDacPacTask =  Resolve-Path "$CurrentFolder\..\PublishDacPacTask\PublishDacPacTask.ps1";
#Write-host $PublishDacPacTask

$ServerName = "SZRH3012.qregroup.net";

Describe "PublishDacPacTask" {

    Context "Deploy Database with New-Guid" {
        It "Database should be deployed with CI publish profile" {
            $DatabaseName = New-Guid;
            $env:INPUT_DacPacPath = $DacPacPath;
            $env:INPUT_DacPublishProfile = $DacProfile;
            $env:INPUT_TargetServerName = $ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishDacPacTask));

            ( Ping-SqlDatabase -Server $ServerName -Database $DatabaseName ) | Should -Be $true;
        }

        It "Database should be deployed with LOCAL publish profile" {
            $DatabaseName = New-Guid;
            $env:INPUT_DacPacPath = $DacPacPath;
            $env:INPUT_DacPublishProfile = $AltDacProfilePath;
            $env:INPUT_TargetServerName = $ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishDacPacTask));

            ( Ping-SqlDatabase -Server $ServerName -Database $DatabaseName ) | Should -Be $true;
        }
    }

}

Remove-Module VstsTaskSdk;

