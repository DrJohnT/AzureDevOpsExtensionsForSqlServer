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
$UpdateTabularCubeDataSource =  Resolve-Path "$CurrentFolder\..\UpdateTabularCubeDataSourceTask\UpdateTabularCubeDataSource.ps1";
$ProcessTabularModelTask =  Resolve-Path "$CurrentFolder\..\ProcessTabularModelTask\ProcessTabularModel.ps1";
$UnpublishTabularModelTask =  Resolve-Path "$CurrentFolder\..\DropCubeTask\UnpublishTabularModel.ps1";
#Write-host $PublishTabularModelTask

$AsServer = "localhost";
$DbServer = "localhost";

Describe "Integration tests" {

    Context "Deploy Cube Model with New-Guid Name, change connection to ImpersonateServiceAccount, process full and then drop" {

        $CubeDatabaseName = New-Guid;

        It "Tabular model should be deployed" {
            $env:INPUT_AsDatabasePath = $AsDatabasePath;
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $AsServer -CubeDatabase $CubeDatabaseName ) | Should -Be $true;
        }

        It "Update cube connection string to ImpersonateServiceAccount process full" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_SourceSqlServer = $DbServer;
            $env:INPUT_SourceSqlDatabase = 'DatabaseToPublish';
            $env:INPUT_ImpersonationMode = 'ImpersonateServiceAccount';
            $env:INPUT_ImpersonationAccount = '';
            $env:INPUT_ImpersonationPassword = '';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($UpdateTabularCubeDataSource));

            # prove it worked by processing the cube
            { Invoke-ProcessASDatabase -Server $AsServer -DatabaseName $CubeDatabaseName -RefreshType Full }  | Should Not Throw;
        }

        It "Unpublish cube should delete cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($UnpublishTabularModelTask));

            ( Ping-SsasDatabase -Server $AsServer -CubeDatabase $CubeDatabaseName ) | Should -Be $false;
        }
    }

    Context "Deploy Cube Model with New-Guid Name, change connection to ImpersonateAccount, process full and then drop" {

        $CubeDatabaseName = New-Guid;

        It "Tabular model should be deployed" {
            $env:INPUT_AsDatabasePath = $AsDatabasePath;
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $AsServer -CubeDatabase $CubeDatabaseName ) | Should -Be $true;
        }

        It "Update cube connection string to ImpersonateAccount process full" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_SourceSqlServer = $DbServer;
            $env:INPUT_SourceSqlDatabase = 'DatabaseToPublish';
            $env:INPUT_ImpersonationMode = 'ImpersonateAccount';
            $env:INPUT_ImpersonationAccount = 'qregroup\jtunnicliffe';
            $env:INPUT_ImpersonationPassword = '13Lilac!';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($UpdateTabularCubeDataSource));

            # prove it worked by processing the cube
            { Invoke-ProcessASDatabase -Server $AsServer -DatabaseName $CubeDatabaseName -RefreshType Full }  | Should Not Throw;
        }

        It "Process Clear cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'ClearValues';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask));

        }

        It "Process Full cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Full';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask));

        }

        It "Process Calculate cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Calculate';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask));

        }

        It "Process Default cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Automatic';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask));

        }

        It "Unpublish cube should delete cube" {
            $env:INPUT_AsServer = $ServerName;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($UnpublishTabularModelTask));

            ( Ping-SsasDatabase -Server $AsServer -CubeDatabase $CubeDatabaseName ) | Should -Be $false;
        }
    }


}

Remove-Module VstsTaskSdk;

