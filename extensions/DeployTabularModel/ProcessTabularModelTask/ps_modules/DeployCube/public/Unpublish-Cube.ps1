function Unpublish-Cube {
<#
    .SYNOPSIS
    Unpublish-Cube drops a tabular or multidimenstional cube from a SQL Server Analysis Services instance.

    .DESCRIPTION
    Unpublish-Cube drops a tabular or multidimenstional cube from a SQL Server Analysis Services instance.

    .PARAMETER Server
    Name of the SSAS server, including instance and port if required.

    .PARAMETER CubeDatabase
    The name of the cube database to be dropped.

    .PARAMETER Credential
    [Optional] A PSCredential object containing the credentials to connect to the AAS server.

    .EXAMPLE
    Unpublish-Cube -Server $ServerName -CubeDatabase $CubeName;

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/DeployCube
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

        [PSCredential] [Parameter(Mandatory = $false)]
        $Credential = $null
    )

    $asCmd = "<Delete xmlns='http://schemas.microsoft.com/analysisservices/2003/engine'><Object><DatabaseID>$CubeDatabase</DatabaseID></Object></Delete>";
    if ($null -eq $Credential) {
        $returnResult = Invoke-ASCmd -Server $Server -Query $asCmd;
    } else {
        $returnResult = Invoke-ASCmd -Server $Server -Credential $Credential -Query $asCmd;
    }
    
    if (-not ($returnResult -like '*urn:schemas-microsoft-com:xml-analysis:empty*')) {
        throw "Failed to drop cube $CubeDatabase";
    }
}

New-Alias -Name Drop-Cube -Value Unpublish-Cube;