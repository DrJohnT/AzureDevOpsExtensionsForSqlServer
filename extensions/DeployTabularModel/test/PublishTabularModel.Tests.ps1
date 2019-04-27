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

        $CubeDatabase = New-Guid;

        It "Tabular model should be deployed" {
            $env:INPUT_AsDatabasePath = $AsDatabasePath;
            $env:INPUT_AsServer = $ServerName;
            $env:INPUT_CubeDatabaseName = $CubeDatabase;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $ServerName -CubeDatabase $CubeDatabase ) | Should -Be $true;
        }

        It "Drop cube should not throw" {
            # clean up
            { Unpublish-Cube -Server $ServerName -CubeDatabase $CubeDatabase } | Should Not Throw;
        }

        It "Check the cube dropped" {
            ( Ping-SsasDatabase -Server $ServerName -CubeDatabase $CubeDatabase ) | Should Be $false;
        }
    }

    Context "Attempt to deploy cube with Full processing should fail" {
        $CubeDatabase = New-Guid;

        It "Deploy cube with Full processing should fail" {

            $env:INPUT_AsDatabasePath = $AsDatabasePath;
            $env:INPUT_AsServer = $ServerName;
            $env:INPUT_CubeDatabaseName = $CubeDatabase;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "Full";
            $env:INPUT_TransactionalDeployment = "true";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $ServerName -CubeDatabase $CubeDatabase ) | Should Be $false;
        }
    }

}

Remove-Module VstsTaskSdk;

