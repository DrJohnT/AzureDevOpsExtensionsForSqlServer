BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    #write-host  $CurrentFolder
    $psModules =  Resolve-Path "$CurrentFolder\RunSqlCmdScriptTask\ps_modules";
    #write-host  $psModules
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

    function Get-Config {
        $data = @{};
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        
        $data.RunSqlCmdScriptTask = Resolve-Path "$CurrentFolder\RunSqlCmdScriptTask\RunSqlCmdScript.ps1";
        $SqlCmdFolder = Resolve-Path "$CurrentFolder\..\..\examples\SqlCmdScripts\SingleScripts";

        $data.SqlCmdScriptFile1 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd1.sql";
        $data.SqlCmdScriptFile2 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd2.sql";
        $data.SqlCmdScriptFile3 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd3.sql";
        $data.RowCountQuery = "select COUNT(*) as CountOfRows from dbo.MyOtherTable;"
        $data.HasValueQuery = "select MyOtherColumn from dbo.MyOtherTable where MyOtherTableId = 2"
                
        return $data;
    }
}




#Write-Host $SqlCmdFolder


Describe "RunSqlCmdScriptTask" -Tag "RunSqlCmdScripts" {

    Context "Execute Sql Script" {
        BeforeEach {
            Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query "truncate table dbo.MyOtherTable;" -ErrorAction Stop;
        }

        It "Execute plain SQL Script" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile1;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "DatabaseToPublish";
            $env:INPUT_SqlCmdVariableType = 'none'
            $env:INPUT_SqlCmdVariablesInJson = ''
            $env:INPUT_SqlCmdVariablesInText = '';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 1;
        }

        It "Execute SQL Script with two SqlCmdVariables" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile2;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "DatabaseToPublish";
            $env:INPUT_SqlCmdVariableType = 'text'
            $env:INPUT_SqlCmdVariablesInJson = ''
            $env:INPUT_SqlCmdVariablesInText = @"
MyDataValue=Value1
MyDataValue2=Value2
"@
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.HasValueQuery -ErrorAction Stop;
            $results.Item('MyOtherColumn') | Should -Be 'Value2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 2;
        }

        It "Execute Sql Script with three SqlCmdVariables" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile3;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "DatabaseToPublish";
            $env:INPUT_SqlCmdVariableType = 'text'
            $env:INPUT_SqlCmdVariablesInJson = ''
            [string] $sqlCmdValues = @"
NewDataValue1=ThreeValues1
NewDataValue2=ThreeValues2
NewDataValue3=ThreeValues3
"@;
            $env:INPUT_SqlCmdVariablesInText = $sqlCmdValues;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.HasValueQuery -ErrorAction Stop;
            $results.Item('MyOtherColumn') | Should -Be 'ThreeValues2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 3;
        }

        It "Execute Sql Script with specific username/password" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile3;
            $env:INPUT_Server = "localhost";
            $env:INPUT_Database = "DatabaseToPublish";
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_Username = "ea";
            $env:INPUT_Password = "open";
            $env:INPUT_SqlCmdVariableType = 'text'
            $env:INPUT_SqlCmdVariablesInJson = ''
            [string] $sqlCmdValues = @"
NewDataValue1=ThreeValues1
NewDataValue2=ThreeValues2
NewDataValue3=ThreeValues3
"@;
            $env:INPUT_SqlCmdVariablesInText = $sqlCmdValues;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.HasValueQuery -ErrorAction Stop;
            $results.Item('MyOtherColumn') | Should -Be 'ThreeValues2';

            $results = Invoke-Sqlcmd -Server "localhost" -Database "DatabaseToPublish" -Query $data.RowCountQuery -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 3;
        }
    }

}

AfterAll {
    Remove-Module VstsTaskSdk;
}

