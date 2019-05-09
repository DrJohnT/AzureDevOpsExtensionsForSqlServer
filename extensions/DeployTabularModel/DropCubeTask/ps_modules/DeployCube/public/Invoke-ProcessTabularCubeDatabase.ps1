function Invoke-ProcessTabularCubeDatabase {
<#
    .SYNOPSIS
    Processes an SSAS database on a SQL Server SSAS instance

    .DESCRIPTION
    Processes an SSAS database on a SQL Server SSAS instance

    .PARAMETER Server
    Name of the target SSAS server, including instance and port if required.

    .PARAMETER CubeDatabase
    The name of the tabular cube database on the SSAS server.

    .PARAMETER RefreshType
    Valid options are: 'Full', 'Automatic', 'ClearValues', 'Calculate'.
    Default value: 'Full'.
    'Full': processes all the objects in the cube database. When Full processing is executed against an object that has already been processed, Analysis Services drops all data in the object and then processes the object.
    'Automatic': detects the process state of cube database objects, and performs the processing necessary to deliver unprocessed or partially processed objects to a fully processed state.
    'ClearValues': Clear values in this object and all its dependents.
    'Calculate': Recalculate this object and all its dependents, but only if needed. This value does not force recalculation, except for volatile formulas.

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
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
