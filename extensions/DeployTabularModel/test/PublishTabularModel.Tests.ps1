# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
#Write-host $CurrentFolder
$mediaFolder =  Resolve-Path "$CurrentFolder\..\..\..\examples";
#Write-host $mediaFolder
$AsDatabasePath = Resolve-Path "$mediaFolder\CubeToPublish\MyTabularProject\bin\Model.asdatabase";

$psModules =  Resolve-Path "$CurrentFolder\..\DeployTabularModelTask\ps_modules";
#Write-host $psModules
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }
#Import-Module "$psModules\PublishDacPac";

$PublishTabularModelTask =  Resolve-Path "$CurrentFolder\..\DeployTabularModelTask\PublishTabularModel.ps1";
#Write-host $PublishTabularModelTask

$ServerName = "localhost";

Describe "PublishTabularModel" {

    Context "Deploy Cube Model with New-Guid as Name" {
        It "Tabular model should be deployed" {
            $DatabaseName = New-Guid;
            $env:INPUT_AsDatabasePath = $AsDatabasePath;
            $env:INPUT_AsServer = $ServerName;
            $env:INPUT_CubeDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $ServerName -CubeDatabase $DatabaseName ) | Should -Be $true;
        }

    }

}

Remove-Module VstsTaskSdk;

