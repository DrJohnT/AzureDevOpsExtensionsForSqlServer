# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$psModules =  Resolve-Path "$CurrentFolder\..\CreateSsisFolderTask\ps_modules";
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

$CreateScriptTask = Resolve-Path "$CurrentFolder\..\CreateSsisFolderTask\CreateSsisFolderTask.ps1";
$DropScriptTask = Resolve-Path "$CurrentFolder\..\DropSsisFolderTask\DropSsisFolderTask.ps1";

#Write-Host $SqlCmdFolder

$ServerName = "localhost";
$DatabaseName = "SSISDB";

Describe "RunSqlCmdScriptTask" {

    Context "Create / drop folder" {
        $SsisFolderName = 'MyCreateDropFolder';

        AfterEach {
            $FolderCountQuery = "select count(*) as CountOfRows from SSISDB.internal.folders where [name] = '$SsisFolderName'";
            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $FolderCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be $global:CountOfRows;
        }

        It "Create folder" {

            $env:INPUT_SqlCmdSciptPath = $SqlCmdScriptFile1;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_Folder = $SsisFolderName;
            $env:INPUT_FolderDescription = 'It was me'
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($CreateScriptTask));

            $global:CountOfRows = 1;
        }

        It "Drop folder" {

            $env:INPUT_SqlCmdSciptPath = $SqlCmdScriptFile1;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_Folder = $SsisFolderName;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($DropScriptTask));

            $global:CountOfRows = 0;
        }
    }
}

Remove-Module VstsTaskSdk;

