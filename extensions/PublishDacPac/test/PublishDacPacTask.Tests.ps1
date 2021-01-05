BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    $psModules =  Resolve-Path "$CurrentFolder\PublishDacPacTask\ps_modules";
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

    function Get-Config {
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        
        $mediaFolder =  Resolve-Path "$CurrentFolder\..\..\examples";
        
        $DacPac = "DatabaseToPublish.dacpac";
        $DacPacFolder = Resolve-Path "$mediaFolder\DatabaseToPublish\bin\Debug";

        $data = @{};
        $data.PublishDacPacTask =  Resolve-Path "$CurrentFolder\PublishDacPacTask\PublishDacPacTask.ps1";        
        
        $data.DacPacPath = Resolve-Path "$DacPacFolder\$DacPac";
        $data.DacProfile = "DatabaseToPublish.CI.publish.xml";
        #$DacProfilePath = Resolve-Path "$DacPacFolder\$DacProfile";
        $data.AltDacProfilePath = Resolve-Path "$mediaFolder\DatabaseToPublish\DatabaseToPublish.LOCAL.publish.xml";
        #Write-host $AltDacProfilePath
        $data.ServerName = "localhost";
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

Describe "PublishDacPacTask" {

    Context "Deploy Database with New-Guid" {
        It "Database should be deployed with CI publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.DacProfile;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }

        It "Database should be deployed with LOCAL publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.AltDacProfilePath;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "latest";

            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }
    }

    Context "Deploy Database with SqlCmdVariables" {

        It "Deploy Database with JSON SqlCmdVariables with LOCAL publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.AltDacProfilePath;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "150";
            $env:INPUT_SqlCmdVariableType = "json";
            $env:INPUT_SqlCmdVariablesInJson = $data.SqlCmdVariablesInJson;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }

        It "Deploy Database with TEXT SqlCmdVariables with LOCAL publish profile" {
            $data = Get-Config;
            $DatabaseName = New-Guid;
            $env:INPUT_DacPacPath = $data.DacPacPath;
            $env:INPUT_DacPublishProfile = $data.AltDacProfilePath;
            $env:INPUT_TargetServerName = $data.ServerName;
            $env:INPUT_TargetDatabaseName = $DatabaseName;
            $env:INPUT_PreferredVersion = "150";
            $env:INPUT_SqlCmdVariableType = "text";
            $env:INPUT_SqlCmdVariablesInText = $data.SqlCmdVariablesInText;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.PublishDacPacTask));

            ( Ping-SqlDatabase -Server $data.ServerName -Database $DatabaseName ) | Should -Be $true;
        }
    }
}

AfterAll {
    Remove-Module VstsTaskSdk;
}



