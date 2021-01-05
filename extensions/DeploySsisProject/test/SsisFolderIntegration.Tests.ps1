# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;

    $psModules =  Resolve-Path "$CurrentFolder\CreateSsisFolderTask\ps_modules";
    
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

    function Get-Config {
        $data = @{};
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        $SsisFolderName = 'MyTestFolder';
        $data.CreateScriptTask = Resolve-Path "$CurrentFolder\CreateSsisFolderTask\CreateSsisFolderTask.ps1";
        $data.DropScriptTask = Resolve-Path "$CurrentFolder\DropSsisFolderTask\DropSsisFolderTask.ps1";
        $data.ServerName = "localhost";
        $data.DatabaseName = "SSISDB";
        $data.SsisFolderName = $SsisFolderName;
        $data.FolderCountQuery = "select count(*) as CountOfRows from SSISDB.internal.folders where [name] = '$SsisFolderName'";
        return $data;
    }
}    
    
Describe "RunSqlCmdScriptTask" -Tag "DeploySsisProject" {

    Context "Create and then drop folder" {
        It "Create folder" {
            $data = Get-Config;

            $env:INPUT_SqlCmdSciptPath =  $data.SqlCmdScriptFile1;
            $env:INPUT_Server =  $data.ServerName;
            $env:INPUT_Database = $data.DatabaseName;
            $env:INPUT_Folder = $data.SsisFolderName;
            $env:INPUT_FolderDescription = 'Create folder test';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.CreateScriptTask));

            $results = Invoke-Sqlcmd -Server $data.ServerName -Database $data.DatabaseName -Query $data.FolderCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 1;
        }

        It "Drop folder" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile1;
            $env:INPUT_Server = $data.ServerName;
            $env:INPUT_Database = $data.DatabaseName;
            $env:INPUT_Folder = $data.SsisFolderName;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.DropScriptTask));

            $results = Invoke-Sqlcmd -Server $data.ServerName -Database $data.DatabaseName -Query $data.FolderCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 0;
        }
    }
}

AfterAll {
    Remove-Module VstsTaskSdk;    
}

