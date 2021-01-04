function Get-SqlAsPath {
<#
    .SYNOPSIS
    Returns the path to a specific cube database in the form:
        SQLSERVER:\SQLAS\YourServer\DEFAULT\Databases\YourCubeDatabase
    or
        SQLSERVER:\SQLAS\YourServer\YourInstance\Databases\YourCubeDatabase
    Useful, when wishing to use the SqlServer module to navigate a cube structure.

    .DESCRIPTION
    Returns the path to a specific cube database in the form:
        SQLSERVER:\SQLAS\YourServer\DEFAULT\Databases\YourCubeDatabase
    or
        SQLSERVER:\SQLAS\YourServer\YourInstance\Databases\YourCubeDatabase
    Useful, when wishing to use the SqlServer module to navigate a cube structure.

    .PARAMETER Server
    Name of the SSAS server, including instance and port if required.

    .PARAMETER CubeDatabase
    The name of the cube database to be deployed.

    .EXAMPLE
    Get-SqlAsPath -Server localhost -CubeDatabase MyTabularCube;

    Returns
        SQLSERVER:\SQLAS\localhost\DEFAULT\Databases\MyTabularCube

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
        $Server,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $CubeDatabase
    )
    if ($Server -like "*\*") {
        $returnValue = "SQLSERVER:\SQLAS\$Server\Databases\$CubeDatabase";
    } else {
        $returnValue = "SQLSERVER:\SQLAS\$Server\DEFAULT\Databases\$CubeDatabase";
    }
    return $returnValue;
}