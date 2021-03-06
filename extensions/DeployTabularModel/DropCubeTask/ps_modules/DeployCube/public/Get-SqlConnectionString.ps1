function Get-SqlConnectionString {
<#
    .SYNOPSIS
    Updates a connection strings to source SQL databases with new server and database names.

    .DESCRIPTION
    Helper function to help create valid connection strings to source SQL databases.

    .PARAMETER SourceSqlServer
    Name of the SQL server, including instance and port if required.

    .PARAMETER SourceSqlDatabase
    Name of the source SQL database.

    .PARAMETER ExistingConnectionString
    The existing SQL connection string obtained from the cube definition or config file.

    .PARAMETER SqlUserID
     $SqlUserID 
     
    .PARAMETER SqlUserPassword $SqlUserPassword;

    .EXAMPLE
    Get-SqlConnectionString -SourceSqlServer myserver -SourceSqlDatabase mydatabase -ExistingConnectionString 'Provider=SQLNCLI11;Data Source=localhost;Initial Catalog=DatabaseToPublish;Integrated Security=SSPI;Persist Security Info=false';

    Returns
    'Provider=SQLNCLI11;Data Source=myserver;Persist Security Info=False;Integrated Security=SSPI;Initial Catalog=mydatabase'

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/DeployCube
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [OutputType([string])]
    [CmdletBinding()]
	param
	(
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $SourceSqlServer,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $SourceSqlDatabase,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ExistingConnectionString,

        [String] [Parameter(Mandatory = $false)]
        $SqlUserID = $null, 
        
        [String] [Parameter(Mandatory = $false)]
        $SqlUserPwd = $null
	)

    if ($SourceSqlServer -like "*windows.net*") {
        
        # Azure SQL Server
        $ConnBuilder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder;
        $ConnBuilder["Provider"] = "SQLNCLI11";
        $ConnBuilder["Data Source"] = $SourceSqlServer;
        $ConnBuilder["Initial Catalog"] = $SourceSqlDatabase;
        $ConnBuilder["MultipleActiveResultSets"] = "False";
        $ConnBuilder["Encrypt"] = "True";
        #$ConnBuilder["TrustServerCertificate"] = "False";

        if ("" -ne "$SqlUserID") {
            $ConnBuilder["Persist Security Info"] = "True";
            $ConnBuilder["User ID"] = $SqlUserID;
            $ConnBuilder["Password"] = $SqlUserPwd;
        }

    } else {
        # on-prem SQL Server instance
        $ConnBuilder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder($ExistingConnectionString);
        $ConnBuilder["Data Source"] = $SourceSqlServer;
        $ConnBuilder["Initial Catalog"] = $SourceSqlDatabase;
        
    }
        
    return $ConnBuilder.ConnectionString;
}