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

    .PARAMETER AuthenticationMethod
    Indicates which method to use to connect to the target SQL Server instance in order to deploy the database DacPac.
    Valid options are:

        windows    - Windows authentication (default) will be used to deploy the DacPac to the target SQL Server instance
        sqlauth    - SQL Server authentication will be used to deploy the DacPac to the target SQL Server instance
        credential - Use a PSCredential to connect to the SQL Server instance

    .PARAMETER AuthenticationUser
    UserID for the AuthenticationUser
    Only required if AuthenticationMethod = sqlauth
    
    .PARAMETER AuthenticationPassword
    Password for the AuthenticationUser
    Only required if AuthenticationMethod = sqlauth
    
    .PARAMETER AuthenticationCredential
    A PSCredential object containing the credentials to connect to the SQL Server instance
    Only required if AuthenticationMethod = credential

    .EXAMPLE
    Remove-Database -Server 'localhost' -Database 'MyTestDB'

    Connects to the server localhost to remove the database MyTestDB

    .EXAMPLE
    Remove-Database -Server 'localhost' -Database 'MyTestDB' -AuthenticationCredential myCred

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
        
        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('windows', 'sqlauth', 'credential')]
        $AuthenticationMethod = 'windows',

        [String] [Parameter(Mandatory = $false)]
        $AuthenticationUser,

        [String] [Parameter(Mandatory = $false)]
        $AuthenticationPassword,

        [PSCredential] [Parameter(Mandatory = $false)]
        $AuthenticationCredential
    )

    # Now Invoke-Sqlcmd
    $Command = "Invoke-Sqlcmd -ServerInstance '$Server' -Database 'master' -Query 'drop database [$Database]' -OutputSqlErrors 1 -ErrorAction Stop";
   
    if ($AuthenticationMethod -eq 'sqlauth') { 
        [SecureString] $SecurePassword = ConvertTo-SecureString $AuthenticationPassword -AsPlainText -Force;
        [PsCredential] $AuthenticationCredential = New-Object System.Management.Automation.PSCredential($AuthenticationUser, $SecurePassword);
        $Command += ' -Credential $AuthenticationCredential';
    }

    $scriptBlock = [Scriptblock]::Create($Command);  

    if ($AuthenticationMethod -eq 'sqlauth' -or $AuthenticationMethod -eq 'credential') {            
        Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $AuthenticationCredential;
    } else {            
        Invoke-Command -ScriptBlock $scriptBlock;
    }            
}
New-Alias -Name Remove-Database -Value Unpublish-Database;