# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$psModules =  Resolve-Path "$CurrentFolder\..\RunSqlCmdScriptTask\ps_modules";
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

$RunSqlCmdScriptTask =  Resolve-Path "$CurrentFolder\..\RunSqlCmdScriptTask\RunSqlCmdScript.ps1";

$ServerName = "localhost";
$DatabaseName = "MyTestDB4";
$SqlScriptFile = "InsertIntoMyOnlyTable.sql";
$SqlCmdScriptFile1 = "InsertIntoMyOnlyTableSqlCmd1.sql";
$SqlCmdScriptFile3 = "InsertIntoMyOnlyTableSqlCmd3.sql";

Describe "RunSqlCmdScriptTask" {

    Context "Execute Sql Script" {
        It "Execute Sql Script" {

            $ScriptPath = Resolve-Path "$CurrentFolder\$SqlScriptFile";
            $env:INPUT_SqlCmdSciptPath = $ScriptPath;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_SqlCmdVariables = "";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));

        }

        It "Execute Sql Script with single SqlCmdVariable" {
            $ScriptPath = Resolve-Path "$CurrentFolder\$SqlCmdScriptFile1";
            $env:INPUT_SqlCmdSciptPath = $ScriptPath;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_SqlCmdVariables = "MyDataValue=SingleValue";
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));
        }

        It "Execute Sql Script with multiple SqlCmdVariables" {
            $ScriptPath = Resolve-Path "$CurrentFolder\$SqlCmdScriptFile3";
            $env:INPUT_SqlCmdSciptPath = $ScriptPath;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            [string] $sqlCmdValues = @"
NewDataValue1=ThreeValues1
NewDataValue2=ThreeValues2
NewDataValue3=ThreeValues3
"@;
            $env:INPUT_SqlCmdVariables = $sqlCmdValues;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));
        }



    }

}

Remove-Module VstsTaskSdk;

