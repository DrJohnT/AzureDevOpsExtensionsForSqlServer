function Unpublish-Cube {
    <#
		.SYNOPSIS
        Unpublish-Cube drops a tabular or multidimenstional cube from a SQL Server Analysis Services instance.
    #>
    [CmdletBinding()]
	param
	(
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Server,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $CubeDatabase
    )

    # only attempt to drop the cube if it actually exists!
    if ( Ping-SsasDatabase -Server $Server -CubeDatabase $CubeDatabase ) {
        $asCmd = "<Delete xmlns='http://schemas.microsoft.com/analysisservices/2003/engine'><Object><DatabaseID>$CubeDatabase</DatabaseID></Object></Delete>";
        $returnResult = Invoke-ASCmd -Server $Server -Query $asCmd;
        if (-not ($returnResult -like '*urn:schemas-microsoft-com:xml-analysis:empty*')) {
            throw "Failed to drop cube $CubeDatabase";
        }
    }
}

New-Alias -Name Drop-Cube -Value Unpublish-Cube;