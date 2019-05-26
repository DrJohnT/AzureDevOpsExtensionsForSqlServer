# See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$psModules =  Resolve-Path "$CurrentFolder\..\RunSqlCmdScriptsInFolderTask\ps_modules";
Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

$RunSqlCmdScriptTask = Resolve-Path "$CurrentFolder\..\RunSqlCmdScriptsInFolderTask\RunSqlCmdScriptsInFolder.ps1";
$SqlCmdFolder = Resolve-Path "$CurrentFolder\..\..\..\examples\SqlCmdScripts\MultipleScripts";

Write-Host $SqlCmdFolder

$ServerName = "localhost";
$DatabaseName =  "DatabaseToPublish";
$SqlTruncateScript = "truncate table dbo.MyTable";
$RowCountQuery = "select COUNT(*) as CountOfRows from dbo.MyTable;"
$HasValueQuery = "select MyColumn from dbo.MyTable where MyTableId = "

Describe "RunSqlCmdScriptsInFolder" {

    Context "Execute Sql Script" {
        BeforeEach {
            Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $SqlTruncateScript -ErrorAction Stop;
        }

        AfterEach {
            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query $RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be $global:CountOfRows;
        }

        It "Execute Sql Script with five SqlCmdVariables in text format" {
            $env:INPUT_SqlCmdSciptFolderPath = $SqlCmdFolder;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_Recursive = 'true';
            $env:INPUT_SqlCmdVariableType = 'text'

            [string] $sqlCmdValues = @"
MyDataValue1=DataValue1
MyDataValue2=DataValue2
NewDataValue1=ThreeValues1
NewDataValue2=ThreeValues2
NewDataValue3=ThreeValues3
"@;

            $env:INPUT_SqlCmdVariablesInJson = '';
            $env:INPUT_SqlCmdVariablesInText = $sqlCmdValues;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query "$HasValueQuery 3" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'DataValue2';

            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query "$HasValueQuery 5" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'ThreeValues2';

            $global:CountOfRows = 6;
        }

        It "Execute Sql Script with five SqlCmdVariables in JSON format" {
            $env:INPUT_SqlCmdSciptFolderPath = $SqlCmdFolder;
            $env:INPUT_Server = $ServerName;
            $env:INPUT_Database = $DatabaseName;
            $env:INPUT_Recursive = 'false';
            $env:INPUT_SqlCmdVariableType = 'json'
            [string] $sqlCmdValues = @"
            {
                "MyDataValue1": "JsonValue1",
                "MyDataValue2": "JsonValue2",
                "NewDataValue1": "ThreeJsonValues1",
                "NewDataValue2": "ThreeJsonValues2",
                "NewDataValue3": "ThreeJsonValues3"
            }
"@;
            $env:INPUT_SqlCmdVariablesInJson = $sqlCmdValues;
            $env:INPUT_SqlCmdVariablesInText = '';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query "$HasValueQuery 3" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'JsonValue2';

            $results = Invoke-Sqlcmd -Server $ServerName -Database $DatabaseName -Query "$HasValueQuery 5" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'ThreeJsonValues2';

            $global:CountOfRows = 6;
        }
    }

}

Remove-Module VstsTaskSdk;

