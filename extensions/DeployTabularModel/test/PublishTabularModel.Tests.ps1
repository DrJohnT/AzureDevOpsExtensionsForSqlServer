BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    #Write-host $CurrentFolder;
    $psModules =  Resolve-Path "$CurrentFolder\DeployTabularModelTask\ps_modules";
    #Write-host $psModules
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }
}

Describe "PublishTabularModel" -Tag "DeployTabularModel" {

    Context "Deploy Cube Model with New-Guid as Name" {

        It "Tabular model should be deployed" {
            $CubeDatabase = New-Guid;
            $ServerName = "localhost";

            $CurrentFolder = Split-Path -Parent $PSScriptRoot;
            #Write-Host $CurrentFolder 
            $PublishTabularModelTask =  Resolve-Path "$CurrentFolder\DeployTabularModelTask\PublishTabularModel.ps1";
            $AsDatabasePath = Resolve-Path "$CurrentFolder\..\..\examples\CubeAtCompatibility1200\bin\Model.asdatabase";

            $env:INPUT_AsDatabasePath = $AsDatabasePath;
            $env:INPUT_AsServer = $ServerName;
            $env:INPUT_CubeDatabaseName = $CubeDatabase;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_TransactionalDeployment = $False;
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";

            $env:INPUT_SourceSqlServer = $data.DbServer;
            $env:INPUT_SourceSqlDatabase = $data.SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateServiceAccount';
            $env:INPUT_ImpersonationAccount = '';
            $env:INPUT_ImpersonationPassword = '';

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $ServerName -CubeDatabase $CubeDatabase ) | Should -Be $true;

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UpdateTabularCubeDataSource));

            { Unpublish-Cube -Server $ServerName -CubeDatabase $CubeDatabase } | Should -Not -Throw;

            ( Ping-SsasDatabase -Server $ServerName -CubeDatabase $CubeDatabase ) | Should -Be $false;
        }

    }
<#
    Context "Attempt to deploy cube with Full processing should fail" {
        $CubeDatabase = New-Guid;

        It "Deploy cube with Full processing should fail" {

            $env:INPUT_AsDatabasePath = $AsDatabasePath;
            $env:INPUT_AsServer = $ServerName;
            $env:INPUT_CubeDatabaseName = $CubeDatabase;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_TransactionalDeployment = "true";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $ServerName -CubeDatabase $CubeDatabase ) | Should Be $false;
        }
    }
#>
}

AfterAll {
    Remove-Module VstsTaskSdk;
    Remove-Module DeployCube;
}

