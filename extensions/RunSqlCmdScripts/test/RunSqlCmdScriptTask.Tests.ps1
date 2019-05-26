# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$psModules =  Resolve-Path "$CurrentFolder\..\RunSqlCmdScriptTask\ps_modules";
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

$RunSqlCmdScriptTask = Resolve-Path "$CurrentFolder\..\RunSqlCmdScriptTask\RunSqlCmdScript.ps1";
$SqlCmdFolder = Resolve-Path "$CurrentFolder\..\..\..\examples\SqlCmdScripts\SingleScripts";

#Write-Host $SqlCmdFolder

$ServerName = "localhost";
$DatabaseName =  "DatabaseToPublish";
$SqlTruncateScript =  "truncate table dbo.MyOtherTable;";
$SqlCmdScriptFile1 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd1.sql";
$SqlCmdScriptFile2 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd2.sql";
$SqlCmdScriptFile3 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd3.sql";
$RowCountQuery = "select COUNT(*) as CountOfRows from dbo.MyOtherTable;"
$HasValueQuery = "select MyOtherColumn from dbo.MyOtherTable where MyOtherTableId = 2"

Describe "RunSqlCmdScriptTask" {

    Context "Execute Sql Script" {
        BeforeEach {
            Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $SqlTruncateScript -ErrorAction Stop;
        }

        AfterEach {
            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be $global:CountOfRows;
        }

        It "Execute plain SQL Script" {

            $env:INPUT_SqlCmdSciptPath = $SqlCmdScriptFile1;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_SqlCmdVariableType = 'none'
            $env:INPUT_SqlCmdVariablesInJson = ''
            $env:INPUT_SqlCmdVariablesInText = '';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));

            $global:CountOfRows = 1;
        }

        It "Execute SQL Script with two SqlCmdVariables" {
            $env:INPUT_SqlCmdSciptPath = $SqlCmdScriptFile2;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_SqlCmdVariableType = 'text'
            $env:INPUT_SqlCmdVariablesInJson = ''
            $env:INPUT_SqlCmdVariablesInText = @"
MyDataValue=Value1
MyDataValue2=Value2
"@
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $HasValueQuery -ErrorAction Stop;
            $results.Item('MyOtherColumn') | Should -Be 'Value2';

            $global:CountOfRows = 2;
        }

        It "Execute Sql Script with three SqlCmdVariables" {
            $env:INPUT_SqlCmdSciptPath = $SqlCmdScriptFile3;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_SqlCmdVariableType = 'text'
            $env:INPUT_SqlCmdVariablesInJson = ''
            [string] $sqlCmdValues = @"
NewDataValue1=ThreeValues1
NewDataValue2=ThreeValues2
NewDataValue3=ThreeValues3
"@;
            $env:INPUT_SqlCmdVariablesInText = $sqlCmdValues;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $HasValueQuery -ErrorAction Stop;
            $results.Item('MyOtherColumn') | Should -Be 'ThreeValues2';

            $global:CountOfRows = 3;
        }
    }

}

Remove-Module VstsTaskSdk;

