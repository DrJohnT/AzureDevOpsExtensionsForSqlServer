BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    
    $psModules =  Resolve-Path "$CurrentFolder\..\PublishDacPac\PublishDacPacTask\ps_modules";
    
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }
    Import-Module "$psModules\PublishDacPac" -ArgumentList @{ NonInteractive = $true }
    
    function Get-Config {
        $data = @{};
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        #Write-Host $CurrentFolder
        
        $data.AsDatabasePath = Resolve-Path "$CurrentFolder\..\..\examples\CubeAtCompatibility1200\bin\Model.asdatabase";
        $data.PublishDacPacTask =  Resolve-Path "$CurrentFolder\..\PublishDacPac\PublishDacPacTask\PublishDacPacTask.ps1";

        $data.CubeDatabaseName1 = "DeployCubeIntegrationTest1";
        $data.CubeDatabaseName2 = "DeployCubeIntegrationTest2";

        #Write-host $PublishTabularModelTask
        #Write-Host $CurrentFolder 
        $data.PublishTabularModelTask =  Resolve-Path "$CurrentFolder\DeployTabularModelTask\PublishTabularModel.ps1";
        $data.UpdateTabularCubeDataSource =  Resolve-Path "$CurrentFolder\UpdateTabularCubeDataSourceTask\UpdateTabularCubeDataSource.ps1";
        $data.ProcessTabularModelTask =  Resolve-Path "$CurrentFolder\ProcessTabularModelTask\ProcessTabularModel.ps1";
        $data.UnpublishTabularModelTask =  Resolve-Path "$CurrentFolder\DropCubeTask\UnpublishTabularModel.ps1";

        $DacPac = "DatabaseToPublish.dacpac";
        $MediaFolder =  Resolve-Path "$CurrentFolder\..\..\examples";
        $DacPacFolder = Resolve-Path "$mediaFolder\DatabaseToPublish\bin\Debug";
        $data.DacPacPath = Resolve-Path "$DacPacFolder\$DacPac";
        $data.DacProfile = "DatabaseToPublish.CI.publish.xml";
        $data.SqlDatabaseName = 'DatabaseToPublish';
        $data.AsServer = "localhost";
        $data.DbServer = "localhost";
        return $data;
    }
}

Describe "Deploy Cube Integration tests" -Tag "DeployTabularModel" {

    # start by ensuring we have a source database to work with!    
    Context "Deploy DatabaseToPublish" {
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
    
    Context "Deploy Cube Test 1" {

        It "Tabular model deployed" {

            $data = Get-Config;
            $env:INPUT_AsDatabasePath =  $data.AsDatabasePath;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName1;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $data.AsServer -CubeDatabase $data.CubeDatabaseName1 ) | Should -Be $true;
        }

        It "Update connection" {
            $data = Get-Config;
            $env:INPUT_SourceSqlServer = $data.DbServer;
            $env:INPUT_SourceSqlDatabase = $data.SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateServiceAccount';
            $env:INPUT_ImpersonationAccount = '';
            $env:INPUT_ImpersonationPassword = '';

            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UpdateTabularCubeDataSource))  }  | Should -Not -Throw;
        }

        It "Process Clear" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'ClearValues';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Process Calculate" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'Calculate';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Process Full" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'Full';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Process Automatic" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'Automatic';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Drop cube" {
            $data = Get-Config;
            # remove the cube
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UnpublishTabularModelTask));

            # prove it worked by checked if the cube is still on server
            ( Ping-SsasDatabase -Server $data.AsServer -CubeDatabase $data.CubeDatabaseName1 ) | Should -Be $false;
        }

    }

    Context "Deploy Cube Test 2" {

        It "Tabular model deployed" {

            $data = Get-Config;
            $env:INPUT_AsDatabasePath =  $data.AsDatabasePath;
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $data.CubeDatabaseName2;
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_ProcessingOption = "DoNotProcess";
            $env:INPUT_TransactionalDeployment = "false";
            $env:INPUT_PartitionDeployment = "DeployPartitions";
            $env:INPUT_RoleDeployment = "DeployRolesRetainMembers";
            $env:INPUT_ConfigurationSettingsDeployment = "Deploy";
            $env:INPUT_OptimizationSettingsDeployment = "Deploy";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishTabularModelTask));

            ( Ping-SsasDatabase -Server $data.AsServer -CubeDatabase $data.CubeDatabaseName2 ) | Should -Be $true;
        }

        It "Update connection" {
            $data = Get-Config;
            $env:INPUT_SourceSqlServer = $data.DbServer;
            $env:INPUT_SourceSqlDatabase = $data.SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateServiceAccount';
            $env:INPUT_ImpersonationAccount = '';
            $env:INPUT_ImpersonationPassword = '';
            #$env:INPUT_ImpersonationMode = 'ImpersonateAccount';
            #$env:INPUT_ImpersonationAccount = 'uk\vbggvf';
            #$env:INPUT_ImpersonationPassword = 'fggf!!';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UpdateTabularCubeDataSource))  }  | Should -Not -Throw;
        }

        It "Process Clear" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'ClearValues';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Process Calculate" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'Calculate';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Process Full" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'Full';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Process Automatic" {
            $data = Get-Config;
            $env:INPUT_RefreshType = 'Automatic';
            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.ProcessTabularModelTask)) } | Should -Not -Throw;
        }

        It "Drop cube" {
            $data = Get-Config;
            # remove the cube
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UnpublishTabularModelTask));

            # prove it worked by checked if the cube is still on server
            ( Ping-SsasDatabase -Server $data.AsServer -CubeDatabase $data.CubeDatabaseName2 ) | Should -Be $false;
        }

    }
}

AfterAll {
    Remove-Module VstsTaskSdk;
    Remove-Module PublishDacPac;
    Remove-Module DeployCube;
}

