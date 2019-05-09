function Get-SqlDatabasePath {
<#
    .SYNOPSIS
    Returns the path to a specific SQL database in the form:
        SQLSERVER:\SQL\YourServer\DEFAULT\Databases\YourSQLDatabase
    or
        SQLSERVER:\SQL\YourServer\YourInstance\Databases\YourSQLDatabase
    Useful, when wishing to use the SqlServer module to navigate a SQL structure.

    .DESCRIPTION
    Returns the path to a specific SQL database in the form:
        SQLSERVER:\SQL\YourServer\DEFAULT\Databases\YourSQLDatabase
    or
        SQLSERVER:\SQL\YourServer\YourInstance\Databases\YourSQLDatabase
    Useful, when wishing to use the SqlServer module to navigate a SQL structure.

    .PARAMETER Server
    Name of the SSAS server, including instance and port if required.

    .PARAMETER SQLDatabase
    The name of the SQL database to be deployed.

    .EXAMPLE
    Get-SqlAsPath -Server localhost -SQLDatabase MySQLDB;

    Returns
        SQLSERVER:\SQL\localhost\DEFAULT\Databases\MySQLDB

    .EXAMPLE
    Get-SqlAsPath -Server mydevserver\instance1 -SQLDatabase MySQLDB;

    Returns
        SQLSERVER:\SQL\mydevserver\instance1\Databases\MySQLDB

    .LINK
    https://github.com/DrJohnT/PublishDacPac

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
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
        $Database
    )
    if ($Server -like "*\*") {
        $returnValue = "SQLSERVER:\SQL\$Server\Databases\$Database";
    } else {
        $returnValue = "SQLSERVER:\SQL\$Server\DEFAULT\Databases\$Database";
    }
    return $returnValue;
}