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
        
        $ServerInstance = $Env:ServerInstance;
        if ("$ServerInstance" -eq "") {
            Write-Host "Setting local env variables";
            $Env:ServerInstance   = "localhost"; 
            $Env:Database = "DatabaseToPublish";
            $Env:AuthenticationUser   = "ea"; 
            $Env:AuthenticationPassword = "open";
        }
        $data.ServerInstance = $Env:ServerInstance;
        $data.Database = $Env:Database;
        $data.AuthenticationUser = $Env:AuthenticationUser; 
        $data.AuthenticationPassword = $Env:AuthenticationPassword;

        [SecureString] $SecurePassword = ConvertTo-SecureString $data.AuthenticationPassword -AsPlainText -Force;
        [PsCredential] $data.Credential = New-Object System.Management.Automation.PSCredential($data.AuthenticationUser, $SecurePassword);

        $data.RunSqlCmdScriptsInFolderTask = Resolve-Path "$CurrentFolder\RunSqlCmdScriptsInFolderTask\RunSqlCmdScriptsInFolder.ps1";
        $data.SqlCmdFolder = Resolve-Path "$CurrentFolder\..\..\examples\SqlCmdScripts\MultipleScripts";
        $data.PlainScripts = Resolve-Path "$CurrentFolder\..\..\examples\SqlCmdScripts\PlainScripts";
        
        $data.RowCountQuery = "select COUNT(*) as CountOfRows from dbo.MyTable;";
        $data.HasValueQuery = "select MyColumn from dbo.MyTable where MyTableId = ";

        return $data;
    }
}

Describe "RunSqlCmdScriptsInFolder" -Tag Azure,OnPrem {

    Context "Execute Sql Script" {
        BeforeEach {
            $data = Get-Config;
            Invoke-Sqlcmd -ServerInstance $data.ServerInstance -Database $data.Database -Query "truncate table dbo.MyTable" -Credential $data.Credential -ErrorAction Stop;
        }

        It "Execute plain SQL Script in folder" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptFolderPath = $data.PlainScripts;
            $env:INPUT_Server = $data.ServerInstance;
            $env:INPUT_Database = $data.Database;
            $env:INPUT_Recursive = 'false';
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AuthenticationPassword;             
            $env:INPUT_SqlCmdVariableType = 'none'
            $env:INPUT_SqlCmdVariablesInJson = ''
            $env:INPUT_SqlCmdVariablesInText = '';
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptsInFolderTask));

            $results = Invoke-Sqlcmd -ServerInstance $data.ServerInstance -Database $data.Database -Query $data.RowCountQuery -Credential $data.Credential -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 6;
        }

        It "Execute Sql Script with five SqlCmdVariables in text format" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptFolderPath = $data.SqlCmdFolder;
            $env:INPUT_Server = $data.ServerInstance;
            $env:INPUT_Database = $data.Database;
            $env:INPUT_Recursive = 'true';
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AuthenticationPassword;          
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
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptsInFolderTask));

            $query = $data.HasValueQuery;

            $results = Invoke-Sqlcmd -ServerInstance  $data.ServerInstance -Database $data.Database -Query "$query 3" -Credential $data.Credential -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'DataValue2';

            $results = Invoke-Sqlcmd -ServerInstance  $data.ServerInstance -Database $data.Database -Query "$query 5" -Credential $data.Credential -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'ThreeValues2';

            $results = Invoke-Sqlcmd -ServerInstance  $data.ServerInstance -Database $data.Database -Query $data.RowCountQuery -Credential $data.Credential -ErrorAction Stop;

        }

        It "Execute Sql Script with five SqlCmdVariables in JSON format" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptFolderPath = $data.SqlCmdFolder;
            $env:INPUT_Server = $data.ServerInstance;
            $env:INPUT_Database = $data.Database;
            $env:INPUT_Recursive = 'false';
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AuthenticationPassword;           
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
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptsInFolderTask));

            $query = $data.HasValueQuery;
            
            $results = Invoke-Sqlcmd -ServerInstance  $data.ServerInstance -Database $data.Database -Query "$query 3" -Credential $data.Credential -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'JsonValue2';

            $results = Invoke-Sqlcmd -ServerInstance  $data.ServerInstance -Database $data.Database -Query "$query 5" -Credential $data.Credential -ErrorAction Stop;
            $results.Item('MyColumn') | Should -Be 'ThreeJsonValues2';

            $results = Invoke-Sqlcmd -ServerInstance  $data.ServerInstance -Database $data.Database -Query $data.RowCountQuery -Credential $data.Credential -ErrorAction Stop;
            $results.Item('CountOfRows') | Should -Be 6;
        }
    }

}

AfterAll {
    Remove-Module VstsTaskSdk;
}