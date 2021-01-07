function Remove-Database {
<#
    .SYNOPSIS
    Removes (Drops) the specified SQL database

    .DESCRIPTION
    Removes / Drops the specified SQL database from the SQL Server instance

    .PARAMETER Server
    Name of the target server, including instance and port if required.

    .PARAMETER Database
    The name of the database to be deleted.

    .PARAMETER Credential
    [Optional] A PSCredential object containing the credentials to connect to the AAS server.

    .EXAMPLE
    Remove-Database -Server 'localhost' -Database 'MyTestDB'

    Connects to the server localhost to remove the database MyTestDB

    .EXAMPLE
    Remove-Database -Server 'localhost' -Database 'MyTestDB' -Credential myCred

    Connects to the server localhost using the credential supplied in myCred to remove the database MyTestDB

    .LINK
    https://github.com/DrJohnT/PublishDacPac

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/PublishDacPac
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
        $Database,

        [PSCredential] [Parameter(Mandatory = $false)]
        $Credential = $null
    )

    $sqlCmd = "drop database [$Database]";
    if ($null -eq $Credential) {
        Invoke-Sqlcmd -Server $Server -Database 'master' -Query $sqlCmd -ErrorAction Stop;
    } else {
        Invoke-Sqlcmd -Server $Server -Database 'master' -Query $sqlCmd -ErrorAction Stop -Credential $Credential;
    }
    
}
New-Alias -Name Remove-Database -Value Unpublish-Database;