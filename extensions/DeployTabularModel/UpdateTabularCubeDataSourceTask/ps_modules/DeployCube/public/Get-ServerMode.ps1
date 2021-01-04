function Get-ServerMode {
<#
    .SYNOPSIS
    Returns the mode of the SSAS server: Tabular or Multidimensional

    .DESCRIPTION
    Returns the mode of the SSAS server: Tabular or Multidimensional

    .PARAMETER Server
    Name of the SSAS server, including instance and port if required.

    .EXAMPLE
    Get-ServerMode -Server localhost;

    Returns 'Tabular'

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/DeployCube
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Server
    )
    $returnValue = "";
    try {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") | Out-Null;
        $ssasServer = New-Object Microsoft.AnalysisServices.Server;
        $ssasServer.connect($Server);
        if ($ssasServer.Connected -eq $false) {
            throw "SSAS server $Server does not exist";
        }
        $returnValue = $ssasServer.ServerMode;
        $ssasServer.disconnect();
    } catch {
        throw "SSAS server $Server does not exist";
    }

    return $returnValue;
}
