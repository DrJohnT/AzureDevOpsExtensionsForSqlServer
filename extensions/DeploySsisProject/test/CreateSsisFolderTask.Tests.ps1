
BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    #Write-host $CurrentFolder;
    $psModules =  Resolve-Path "$CurrentFolder\CreateSsisFolderTask\ps_modules";
    #Write-host $psModules
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }
}

Describe "RunSqlCmdScriptTask" -Tag "DeploySsisProject" {

    Context "Create folder" {
        It "Create folder" {
            $CurrentFolder = Split-Path -Parent $PSScriptRoot;            
            $ScriptTask = Resolve-Path "$CurrentFolder\CreateSsisFolderTask\CreateSsisFolderTask.ps1";

            $env:INPUT_SqlCmdSciptPath = $SqlCmdScriptFile1;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "SSISDB";
            $env:INPUT_Folder = 'MySsisFolder';
            $env:INPUT_FolderDescription = 'It was my Ssis deployment';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ScriptTask));
        }
    }

}

AfterAll {
    Remove-Module VstsTaskSdk;
}


