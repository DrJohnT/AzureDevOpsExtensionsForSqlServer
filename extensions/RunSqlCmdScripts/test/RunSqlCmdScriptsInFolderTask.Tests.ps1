BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    #write-host  $CurrentFolder
    $psModules =  Resolve-Path "$CurrentFolder\RunSqlCmdScriptsInFolderTask\ps_modules";
    #write-host  $psModules
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

    function Get-Config {
        $data = @{};
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        
        $data.RunSqlCmdScriptTask = Resolve-Path "$CurrentFolder\RunSqlCmdScriptsInFolderTask\RunSqlCmdScriptsInFolder.ps1";
        $data.SqlCmdFolder = Resolve-Path "$CurrentFolder\..\..\examples\SqlCmdScripts\MultipleScripts";
        
        $data.RowCountQuery = "select COUNT(*) as CountOfRows from dbo.MyTable;";
        $data.HasValueQuery = "select MyColumn from dbo.MyTable where MyTableId = ";

        return $data;
    }
}

Describe "RunSqlCmdScriptsInFolder" {

    Context "Execute Sql Script" {
        BeforeEach {
            Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "truncate table dbo.MyTable" -ErrorAction Stop;
        }

        It "Execute Sql Script with five SqlCmdVariables in text format" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptFolderPath = $data.SqlCmdFolder;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "DatabaseToPublish";
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
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $query = $data.HasValueQuery;

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "$query 3" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'DataValue2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "$query 5" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'ThreeValues2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 6;

        }

        It "Execute Sql Script with five SqlCmdVariables in JSON format" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptFolderPath = $data.SqlCmdFolder;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "DatabaseToPublish";
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
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $query = $data.HasValueQuery;
            
            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "$query 3" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'JsonValue2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "$query 5" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'ThreeJsonValues2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 6;
        }

        It "Execute Sql Script with specific username/password" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptFolderPath = $data.SqlCmdFolder;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "DatabaseToPublish";
            $env:INPUT_Recursive = 'false';
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_Username = "ea";
            $env:INPUT_Password = "open";
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
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $query = $data.HasValueQuery;
            
            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "$query 3" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'JsonValue2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "$query 5" -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'ThreeJsonValues2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 6;
        }
    }

}

AfterAll {
    Remove-Module VstsTaskSdk;
}