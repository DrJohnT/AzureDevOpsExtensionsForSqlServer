BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;

    $psModules =  Resolve-Path "$CurrentFolder\..\..\PublishDacPac\PublishDacPacTask\ps_modules";
    #Write-host $psModules
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }
    Import-Module "$psModules\PublishDacPac" -ArgumentList @{ NonInteractive = $true }
    
    function Get-Config {
        $data = @{};
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        
        $data.MediaFolder =  Resolve-Path "$CurrentFolder\..\..\..\examples";
        $data.AsDatabasePath = Resolve-Path "$CurrentFolder\..\..\..\examples\CubeToPublish\MyTabularProject\bin\Model.asdatabase";

        $data.PublishDacPacTask =  Resolve-Path "$CurrentFolder\..\..\PublishDacPac\PublishDacPacTask\PublishDacPacTask.ps1";
        $data.PublishTabularTask =  Resolve-Path "$CurrentFolder\..\DeployTabularModelTask\PublishTabularModel.ps1";
        $data.UpdateTabularCubeDataSource =  Resolve-Path "$CurrentFolder\..\UpdateTabularCubeDataSourceTask\UpdateTabularCubeDataSource.ps1";
        $data.ProcessTabularModelTask =  Resolve-Path "$CurrentFolder\..\ProcessTabularModelTask\ProcessTabularModel.ps1";
        $data.UnpublishTabularModelTask =  Resolve-Path "$CurrentFolder\..\DropCubeTask\UnpublishTabularModel.ps1";
        #Write-host $PublishTabularModelTask
        $data.DacPac = "DatabaseToPublish.dacpac";
        $data.DacPacFolder = Resolve-Path "$mediaFolder\DatabaseToPublish\bin\Debug";
        $data.DacPacPath = Resolve-Path "$DacPacFolder\$DacPac";
        $data.DacProfile = "DatabaseToPublish.CI.publish.xml";
        $data.SqlDatabaseName = 'DatabaseToPublish';
        $data.AsServer = "localhost";
        $data.DbServer = "localhost";
        return $data;
    }
}

Describe "Integration tests" {

    # start by ensuring we have a source database to work with!
    Context "Deploy Database DatabaseToPublish" {
        It "Database should be deployed with CI publish profile" {
            $data = Get-Config;
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.DacProfile;
            $env:INPUT_TargetServerName = $data.DbServer;
            $env:INPUT_TargetDatabaseName = $data.SqlDatabaseName;;
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.DbServer -Database $data.SqlDatabaseName ) | Should -Be $true;
        }
    }

    Context "Deploy Cube Model with New-Guid Name, change connection to ImpersonateServiceAccount, process full and then drop" {

        $CubeDatabaseName = New-Guid;

        It "Tabular model should be deployed" {
            $data = Get-Config;
            $env:INPUT_AsDatabasePath =  $data.AsDatabasePath;
            $env:INPUT_AsServer =  $data.AsServer;
            $env:INPUT_CubeDatabaseName =  $data.CubeDatabaseName;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create( $data.PublishTabularModelTask));

            ( Ping-SsasDatabase -Server  $data.AsServer -CubeDatabase  $data.CubeDatabaseName ) | Should -Be $true;
        }

        It "Update cube connection string to ImpersonateServiceAccount process full" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.$CubeDatabaseName;
            $env:INPUT_SourceSqlServer = $data.DbServer;
            $env:INPUT_SourceSqlDatabase = $data.SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateServiceAccount';
            $env:INPUT_ImpersonationAccount = '';
            $env:INPUT_ImpersonationPassword = '';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UpdateTabularCubeDataSource))  }  | Should -Not -Throw;

            # prove it worked by processing the cube
            { Invoke-ProcessASDatabase -Server $data.AsServer -DatabaseName $data.CubeDatabaseName -RefreshType Full }  | Should -Not -Throw;
        }

        It "Process Clear cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_RefreshType = 'ClearValues';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }

        It "Process Full cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_RefreshType = 'Full';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }

        It "Process Calculate cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.$CubeDatabaseName;
            $env:INPUT_RefreshType = 'Calculate';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }

        It "Process Default cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_RefreshType = 'Automatic';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }

        It "Unpublish cube should delete cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UnpublishTabularModelTask));

            ( Ping-SsasDatabase -Server $data.AsServer -CubeDatabase $data.CubeDatabaseName ) | Should -Be $false;
        }
    }

    Context "Deploy Cube Model with New-Guid Name, change connection to ImpersonateAccount, process full and then drop" {

        #$CubeDatabaseName = New-Guid;

        It "Tabular model should be deployed" {
            $data = Get-Config;
            $env:INPUT_AsDatabasePath = $data.AsDatabasePath;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $AsServer -CubeDatabase $CubeDatabaseName ) | Should -Be $true;
        }

        It "Update cube connection string to ImpersonateAccount process full" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_SourceSqlServer = $data.DbServer;
            $env:INPUT_SourceSqlDatabase = $data.SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateAccount';
            $env:INPUT_ImpersonationAccount = 'QREGROUP\QReSvcSWBuild';
            $env:INPUT_ImpersonationPassword = 'OSzkzmvdVC-n9+BT';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UpdateTabularCubeDataSource));

            # prove it worked by processing the cube
            { Invoke-ProcessASDatabase -Server $AsServer -DatabaseName $CubeDatabaseName -RefreshType Full }  | Should -Not -Throw;
        }

        It "Process Clear cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_RefreshType = 'ClearValues';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }

        It "Process Full cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_RefreshType = 'Full';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }

        It "Process Calculate cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_RefreshType = 'Calculate';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }

        It "Process Default cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            $env:INPUT_RefreshType = 'Automatic';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;

        }


        It "Unpublish cube should delete cube" {
            $data = Get-Config;
            $env:INPUT_AsServer = $data.ServerName;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UnpublishTabularModelTask));

            ( Ping-SsasDatabase -Server $data.AsServer -CubeDatabase $data.CubeDatabaseName ) | Should -Be $false;
        }
    }
}

AfterAll {
    Remove-Module VstsTaskSdk;
    Remove-Module PublishDacPac;
}

