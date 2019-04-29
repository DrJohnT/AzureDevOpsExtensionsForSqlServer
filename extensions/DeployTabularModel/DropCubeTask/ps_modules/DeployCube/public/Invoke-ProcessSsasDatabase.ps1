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

    if ( Ping-SsasDatabase -Server $Server -CubeDatabase $CubeDatabase ) {

        Write-Output "Processing tabular cube $Server.$CubeDatabase using Refresh Type: $RefreshType";

        $tmslStructure = [pscustomobject]@{
            refresh = [pscustomobject]@{
                type = $RefreshType
                objects = @( [pscustomobject]@{ database = $CubeDatabase } )
            }
        }

        $tmsl = $tmslStructure | ConvertTo-Json -Depth 3;
        #Write-Output $tmsl;

        $returnResult = Invoke-ASCmd -Server $Server -ConnectionTimeout 1 -Query $tmsl;
        Get-SsasProcessingMessages -ASCmdReturnString $returnResult;
    } else {
        throw "Cube database $CubeDatabase not found on SSAS Server: $Server";
    }
}
