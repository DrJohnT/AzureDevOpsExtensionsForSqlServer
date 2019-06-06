# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$psModules =  Resolve-Path "$CurrentFolder\..\CreateSsisFolderTask\ps_modules";
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

$ScriptTask = Resolve-Path "$CurrentFolder\..\CreateSsisFolderTask\CreateSsisFolderTask.ps1";

#Write-Host $SqlCmdFolder

$ServerName = "localhost";

Describe "RunSqlCmdScriptTask" {

    Context "Create folder" {
        It "Create folder" {

            $env:INPUT_SqlCmdSciptPath = $SqlCmdScriptFile1;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = "SSISDB";
            $env:INPUT_Folder = 'MySsisFolder'
            $env:INPUT_FolderDescription = 'It was me'
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($ScriptTask));
        }
    }

}

Remove-Module VstsTaskSdk;

