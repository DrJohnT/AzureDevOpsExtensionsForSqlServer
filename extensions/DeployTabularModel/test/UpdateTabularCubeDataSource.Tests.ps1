BeforeAll {
    # See https://github.com/Microsoft/azure-pipelines-task-lib/blob/master/powershell/Docs/TestingAndDebugging.md
    $CurrentFolder = Split-Path -Parent $PSScriptRoot;
    #Write-host $CurrentFolder;
    $psModules =  Resolve-Path "$CurrentFolder\UpdateTabularCubeDataSourceTask\ps_modules";
    #Write-host $psModules
    Import-Module "$psModules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

    
    function Get-Config {
        $data = @{};
        $CurrentFolder = Split-Path -Parent $PSScriptRoot;
        #Write-Host $CurrentFolder
        $data.UpdateTabularCubeDataSource =  Resolve-Path "$CurrentFolder\UpdateTabularCubeDataSourceTask\UpdateTabularCubeDataSource.ps1";

        $data.AsServer = "localhost";

        $data.DbServer = "localhost";
        $data.SqlDatabaseName = 'DatabaseToPublish';
        return $data;
    }
}


Describe "UpdateTabularCubeDataSourceTask" -Tag "DeployTabularModel" {

    Context "Deploy Cube Model with New-Guid as Name" {

        It "Update connection" {
            $data = Get-Config;

            $CubeDatabase = "EssentialsAccountsCube";
            $env:INPUT_AsServer = $data.AsServer;
            $env:INPUT_CubeDatabaseName = $CubeDatabase;
            $env:INPUT_SourceSqlServer = $data.DbServer;
            $env:INPUT_SourceSqlDatabase = $data.SqlDatabaseName;
            $env:INPUT_ImpersonationMode = 'ImpersonateServiceAccount';
            $env:INPUT_ImpersonationAccount = '';
            $env:INPUT_ImpersonationPassword = '';

            ( Ping-SsasDatabase -Server $data.AsServer -CubeDatabase $CubeDatabase ) | Should -Be $true;

            { Invoke-VstsTaskScript -ScriptBlock ([scriptblock]::Create($data.UpdateTabularCubeDataSource))  }  | Should -Not -Throw;

        }

    }

}

AfterAll {
    Remove-Module VstsTaskSdk;
}

