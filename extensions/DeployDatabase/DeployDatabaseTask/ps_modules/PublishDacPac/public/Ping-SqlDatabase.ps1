function Ping-SqlDatabase {
    <#
        .SYNOPSIS
        Checks that the database exists on the SQL Server

        .DESCRIPTION
        Checks that the database exists on the SQL Server instance

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
        This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

        .PARAMETER Server
        Name of the target server, including instance and port if required.

        .PARAMETER Database
        The name of the database you are checking exists.

		.OUTPUTS
        Returns $true if the database is found, $false otherwise.

        .EXAMPLE
        Ping-SqlDatabase -Server localhost -Database 'MyDatabase'

        Find 'MyDatabase' on your local machine


    #>
    [OutputType([Boolean])]
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

    if ($Server -eq $null -or $Server -eq "") {
        return $false;
    }

    try {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null;
        $SmoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $Server;

        # SQL Server instance exists, so check if the database exists
        $SmoDatabase = $SmoServer.Databases[$Database];
        if ($SmoDatabase.Name -eq $Database) {
            return $true;
        }
        else {
            return $false;
        }
    }
    catch {
        Write-Warning "Error $_";
        return $false;
    }
}