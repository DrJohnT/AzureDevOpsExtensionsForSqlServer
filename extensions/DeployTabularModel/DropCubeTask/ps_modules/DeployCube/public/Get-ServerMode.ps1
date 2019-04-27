function Get-ServerMode {
    <#
        .SYNOPSIS
        Returns the mode of the server: Tabular or Multidimensional

        .DESCRIPTION
        Returns the mode of the server: Tabular or Multidimensional

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
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
    #Write-host $ssasServer.SupportedCompatibilityLevels;
    #Write-host $ssasServer.DefaultCompatibilityLevel;

    return $returnValue;
}
