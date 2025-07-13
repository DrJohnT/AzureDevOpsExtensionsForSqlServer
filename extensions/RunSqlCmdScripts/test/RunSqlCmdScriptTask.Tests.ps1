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

        $data.RunSqlCmdScriptTask = Resolve-Path "$CurrentFolder\RunSqlCmdScriptTask\RunSqlCmdScript.ps1";
        $SqlCmdFolder = Resolve-Path "$CurrentFolder\..\..\examples\SqlCmdScripts\SingleScripts";

        $data.SqlCmdScriptFile1 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd1.sql";
        $data.SqlCmdScriptFile2 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd2.sql";
        $data.SqlCmdScriptFile3 =  Resolve-Path "$SqlCmdFolder\InsertIntoMyOtherTableSqlCmd3.sql";
        $data.RowCountQuery = "select COUNT(*) as CountOfRows from dbo.MyOtherTable;";
        $data.HasValueQuery = "select MyOtherColumn from dbo.MyOtherTable where MyOtherTableId = 2";
           
        <#
        Write-Host $data.ServerInstance 
        Write-Host $data.Database
        Write-Host $data.AuthenticationUser
        Write-Host $data.AuthenticationPassword
        Write-Host $data.RunSqlCmdScriptTask    
        Write-Host $SecurePassword
        #>
        return $data;
    }
}

Describe "RunSqlCmdScriptTask" -Tag Azure,OnPrem {

    Context "Execute Sql Script" {
        
        BeforeEach {
            $data = Get-Config;
            Invoke-Sqlcmd -ServerInstance:$data.ServerInstance -Database:$data.Database -Query:"truncate table dbo.MyOtherTable;" -Credential:$data.Credential -ErrorAction:Stop -TrustServerCertificate:$true;
        }

        It "Execute plain SQL Script" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile1;
            $env:INPUT_Server = $data.ServerInstance;
            $env:INPUT_Database = $data.Database;
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AuthenticationPassword;   
            $env:INPUT_TrustServerCertificate = 'true';          
            $env:INPUT_SqlCmdVariableType = 'none'
            $env:INPUT_SqlCmdVariablesInJson = ''
            $env:INPUT_SqlCmdVariablesInText = '';
            $scriptContent = Get-Content $data.RunSqlCmdScriptTask -Raw
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($scriptContent));

            $results = Invoke-Sqlcmd -ServerInstance:$data.ServerInstance -Database:$data.Database -Query:$data.RowCountQuery -Credential:$data.Credential -ErrorAction:Stop -TrustServerCertificate:$true;
            $results.Item('CountOfRows') | Should -Be 1;
        }

        It "Execute SQL Script with two SqlCmdVariables" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile2;
            $env:INPUT_Server = $data.ServerInstance;
            $env:INPUT_Database = $data.Database;
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AuthenticationPassword; 
            $env:INPUT_TrustServerCertificate = 'true';                 
            $env:INPUT_SqlCmdVariableType = 'text';
            $env:INPUT_SqlCmdVariablesInJson = '';
            $env:INPUT_SqlCmdVariablesInText = @"
MyDataValue=Value1
MyDataValue2=Value2
"@
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -ServerInstance:$data.ServerInstance -Database:$data.Database -Query:$data.HasValueQuery -Credential:$data.Credential -ErrorAction:Stop -TrustServerCertificate:$true;
            $results.Item('MyOtherColumn') | Should -Be 'Value2';

            $results = Invoke-Sqlcmd -ServerInstance:$data.ServerInstance -Database:$data.Database -Query:$data.RowCountQuery -Credential:$data.Credential -ErrorAction:Stop -TrustServerCertificate:$true;
            $results.Item('CountOfRows') | Should -Be 2;
        }

        It "Execute Sql Script with three SqlCmdVariables" {
            $data = Get-Config;
            $env:INPUT_SqlCmdSciptPath = $data.SqlCmdScriptFile3;
            $env:INPUT_Server = $data.ServerInstance;
            $env:INPUT_Database = $data.Database;
            $env:INPUT_AuthenticationMethod = "sqlauth";
            $env:INPUT_AuthenticationUser = $data.AuthenticationUser;
            $env:INPUT_AuthenticationPassword = $data.AuthenticationPassword;   
            $env:INPUT_TrustServerCertificate = 'true';              
            $env:INPUT_SqlCmdVariableType = 'text'
            $env:INPUT_SqlCmdVariablesInJson = ''
            [string] $sqlCmdValues = @"
NewDataValue1=ThreeValues1
NewDataValue2=ThreeValues2
NewDataValue3=ThreeValues3
"@;
            $env:INPUT_SqlCmdVariablesInText = $sqlCmdValues;
            Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.RunSqlCmdScriptTask));

            $results = Invoke-Sqlcmd -ServerInstance:$data.ServerInstance -Database:$data.Database -Query:$data.HasValueQuery -Credential:$data.Credential -ErrorAction:Stop -TrustServerCertificate:$true;
            $results.Item('MyOtherColumn') | Should -Be 'ThreeValues2';

            $results = Invoke-Sqlcmd -ServerInstance:$data.ServerInstance -Database:$data.Database -Query:$data.RowCountQuery -Credential:$data.Credential -ErrorAction:Stop -TrustServerCertificate:$true;
            $results.Item('CountOfRows') | Should -Be 3;
        }

       
        
    }
    

}

AfterAll {
    Remove-Module VstsTaskSdk;
}

