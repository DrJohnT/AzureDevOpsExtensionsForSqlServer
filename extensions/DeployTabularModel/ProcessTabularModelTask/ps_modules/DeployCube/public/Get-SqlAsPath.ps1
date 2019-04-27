function Get-SqlAsPath {
    <#
        .SYNOPSIS
        Returns the path to a specific cube database in the form:
            SQLSERVER:\SQLAS\YourServer\DEFAULT\Databases\YourCubeDatabase
        or
            SQLSERVER:\SQLAS\YourServer\YourInstance\Databases\YourCubeDatabase

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
    #>
    [OutputType([String])]
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
    if ($Server -contains "\") {
        $returnValue = "SQLSERVER:\SQLAS\$Server\Databases\$CubeDatabase";
    } else {
        $returnValue = "SQLSERVER:\SQLAS\$Server\DEFAULT\Databases\$CubeDatabase";
    }
    return $returnValue;
}