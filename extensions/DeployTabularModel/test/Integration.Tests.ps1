# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
#Write-host $CurrentFolder
$mediaFolder =  Resolve-Path "$CurrentFolder\..\..\..\examples";
#Write-host $mediaFolder
$AsDatabasePath = Resolve-Path "$mediaFolder\CubeToPublish\MyTabularProject\bin\Model.asdatabase";

$psModules =  Resolve-Path "$CurrentFolder\..\..\PublishDacPac\PublishDacPacTask\ps_modules";
#Write-host $psModules
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }
Import-Module "$psModules\PublishDacPac" -ArgumentList @{ NonInteractive = $true }

$PublishDacPacModelTask =  Resolve-Path "$CurrentFolder\..\..\PublishDacPac\PublishDacPacTask\PublishDacPacTask.ps1";
$PublishTabularModelTask =  Resolve-Path "$CurrentFolder\..\DeployTabularModelTask\PublishTabularModel.ps1";
$UpdateTabularCubeDataSource =  Resolve-Path "$CurrentFolder\..\UpdateTabularCubeDataSourceTask\UpdateTabularCubeDataSource.ps1";
$ProcessTabularModelTask =  Resolve-Path "$CurrentFolder\..\ProcessTabularModelTask\ProcessTabularModel.ps1";
$UnpublishTabularModelTask =  Resolve-Path "$CurrentFolder\..\DropCubeTask\UnpublishTabularModel.ps1";
#Write-host $PublishTabularModelTask
$DacPac = "DatabaseToPublish.dacpac";
$DacPacFolder = Resolve-Path "$mediaFolder\DatabaseToPublish\bin\Debug";
$DacPacPath = Resolve-Path "$DacPacFolder\$DacPac";
$DacProfile = "DatabaseToPublish.CI.publish.xml";
$SqlDatabaseName = 'DatabaseToPublish';
$AsServer = "SZRH3012.qregroup.net";
$DbServer = "SZRH3012.qregroup.net";

Describe "Integration tests" {

    # start by ensuring we have a source database to work with!
    Context "Deploy Database DatabaseToPublish" {
        It "Database should be deployed with CI publish profile" {
            $env:INPUT_DacPacPath = $DacPacPath;
            $env:INPUT_DacPublishProfile = $DacProfile;
            $env:INPUT_TargetServerName = $DbServer;
            $env:INPUT_TargetDatabaseName = $SqlDatabaseName;;
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($PublishDacPacTask));

            ( Ping-SqlDatabase -Server $DbServer -Database $SqlDatabaseName ) | Should -Be $true;
        }
    }

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
            $env:INPUT_SourceSqlDatabase = $SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateServiceAccount';
            $env:INPUT_ImpersonationAccount = '';
            $env:INPUT_ImpersonationPassword = '';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($UpdateTabularCubeDataSource))  }  | Should Not Throw;

            # prove it worked by processing the cube
            { Invoke-ProcessASDatabase -Server $AsServer -DatabaseName $CubeDatabaseName -RefreshType Full }  | Should Not Throw;
        }

        It "Process Clear cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'ClearValues';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

        }

        It "Process Full cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Full';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

        }

        It "Process Calculate cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Calculate';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

        }

        It "Process Default cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Automatic';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

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
            $env:INPUT_SourceSqlDatabase = $SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateAccount';
            $env:INPUT_ImpersonationAccount = 'QREGROUP\QReSvcSWBuild';
            $env:INPUT_ImpersonationPassword = 'OSzkzmvdVC-n9+BT';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($UpdateTabularCubeDataSource));

            # prove it worked by processing the cube
            { Invoke-ProcessASDatabase -Server $AsServer -DatabaseName $CubeDatabaseName -RefreshType Full }  | Should Not Throw;
        }

        It "Process Clear cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'ClearValues';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

        }

        It "Process Full cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Full';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

        }

        It "Process Calculate cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Calculate';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

        }

        It "Process Default cube" {
            $env:INPUT_AsServer = $AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabaseName;
            $env:INPUT_RefreshType = 'Automatic';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ProcessTabularModelTask)) } | Should Not Throw;

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
Remove-Module PublishDacPac;

