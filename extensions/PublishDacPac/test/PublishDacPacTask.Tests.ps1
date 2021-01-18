BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    $psModules =  Resolve-Path "$CurrentFolder\PublishDacPacTask\ps_modules";
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

    function Get-Config {
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        
        $examplesFolder =  Resolve-Path "$CurrentFolder\..\..\examples";
        
        $DacPac = "DatabaseToPublish.dacpac";
        $DacPacFolder = Resolve-Path "$examplesFolder\DatabaseToPublish\bin\Debug";

        $data = @{};
               
        # Azure
        $data.AzureServerInstance = $Env:AzureServerInstance;
        $data.AzureDatabase = $Env:AzureDatabase;
        $data.AzureAuthenticationUser = $Env:AzureAuthenticationUser; 
        $data.AzureAuthenticationPassword = $Env:AzureAuthenticationPassword;

        # OnPrem        
        $data.ServerName = $Env:ServerInstance;
        $data.AuthenticationUser = $Env:AuthenticationUser; 
        $data.AuthenticationPassword = $Env:AuthenticationPassword;


        $data.PublishDacPacTask =  Resolve-Path "$CurrentFolder\PublishDacPacTask\PublishDacPacTask.ps1";        
        
        $data.DacPacPath = Resolve-Path "$DacPacFolder\$DacPac";
        $data.DacProfile = "DatabaseToPublish.CI.publish.xml";
        $data.AltDacProfilePath = Resolve-Path "$examplesFolder\DatabaseToPublish\DatabaseToPublish.LOCAL.publish.xml";

        $AzureDacPac = "DatabaseToPublishToAzureSqlDB.dacpac";
        $AzureDacPacFolder = Resolve-Path "$examplesFolder\DatabaseToPublishToAzureSqlDB\bin\Debug";

        $data.AzureDacPacPath = Resolve-Path "$AzureDacPacFolder\$AzureDacPac";
        $data.AzureDacProfile = "DatabaseToPublishToAzure.Upgrade.publish.xml";

        $data.SqlCmdVariablesInJson = @'
{
    "StagingDBName": "StagingDB1",
    "StagingDBServer": "myserver1"
}
'@;

        $data.SqlCmdVariablesInText = @'
StagingDBName=StagingDB2
StagingDBServer=myserver2
'@;
        return $data;
    }
}       

Describe "PublishDacPacTask" -Tag "PublishDacPac" {

    Context "Deploy Database with New-Guid" -Tag OnPrem {
        It "Database should be deployed with CI publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $DatabaseName = "Test-$DatabaseName";
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.DacProfile;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;

            ( Remove-Database -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }

        It "Database should be deployed with CI publish profile with sqlauth" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $DatabaseName = "Test-$DatabaseName";
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.DacProfile;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;            
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AuthenticationPassword;

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;

            ( Remove-Database -Server $data.ServerName -Database $DatabaseName -AuthenticationUser $data.AuthenticationUser -AuthenticationPassword $data.AuthenticationPassword ) | Should -Be $true;
        }


        It "Database should be deployed with LOCAL publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $DatabaseName = "Test-$DatabaseName";
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.AltDacProfilePath;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_SqlCmdVariableType = "none";
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;

            ( Remove-Database -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }
        
    }

    Context "Deploy Database with SqlCmdVariables" -Tag OnPrem {

        It "Deploy Database with JSON SqlCmdVariables with LOCAL publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $DatabaseName = "Test-$DatabaseName";
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.AltDacProfilePath;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "150";
            $env:INPUT_SqlCmdVariableType = "json";
            $env:INPUT_SqlCmdVariablesInJson = $data.SqlCmdVariablesInJson;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;

            ( Remove-Database -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }

        It "Deploy Database with TEXT SqlCmdVariables with LOCAL publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $DatabaseName = "Test-$DatabaseName";
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.AltDacProfilePath;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "150";
            $env:INPUT_SqlCmdVariableType = "text";
            $env:INPUT_SqlCmdVariablesInText = $data.SqlCmdVariablesInText;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;

            ( Remove-Database -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }
    }

    Context "Deploy Database with SqlCmdVariables to Azure" -Tag Azure {

        It "Database should to Azure be deployed with UPGRADE publish profile" {
            $data = Get-Config;

            $env:INPUT_DacPacPath = $data.AzureDacPacPath;
            $env:INPUT_DacPublishProfile = $data.AzureDacProfile;
            $env:INPUT_TargetServerName = $data.AzureServerInstance;
            $env:INPUT_TargetDatabaseName = $data.AzureDatabase;
            $env:INPUT_SqlCmdVariableType = "none";
            $env:INPUT_PreferredVersion = "latest";
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AzureAuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AzureAuthenticationPassword;   
            $env:INPUT_EncryptConnection = "true";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));
        }

    }
    
}

AfterAll {
    Remove-Module VstsTaskSdk;
    Remove-Module PublishDacPac;
}



