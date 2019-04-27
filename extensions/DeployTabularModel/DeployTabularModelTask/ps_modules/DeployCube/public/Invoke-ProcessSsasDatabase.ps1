function Invoke-ProcessSsasDatabase {
    <#
        .SYNOPSIS
        Processes an SSAS database on a SQL Server SSAS instance

        .DESCRIPTION
        Processes an SSAS database on a SQL Server SSAS instance

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
    #>
    [CmdletBinding()]
    param
    (
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Server,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $CubeDatabase,

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('Full', 'Automatic', 'ClearValues', 'Calculate')]
        $RefreshType = 'Full'
    )

    try {
        # ensure SqlServer module is installed
        Get-ModuleByName -Name SqlServer;

        if ( Ping-SsasDatabase -Server $Server -CubeDatabase $CubeDatabase ) {
            Write-Host "Processing tabular cube database $Server.$CubeDatabase using $RefreshType";
            $ModelOperationResults = Invoke-ProcessASDatabase -Server $Server -DatabaseName $CubeDatabase -RefreshType $RefreshType;
            Get-SsasProcessingMessages $ModelOperationResults;
        } else {
            Write-Error "Tabular cube database $CubeDatabase does not exist on server $Server";
        }
    }
    catch {
        Write-Error "$_";
    }
}
