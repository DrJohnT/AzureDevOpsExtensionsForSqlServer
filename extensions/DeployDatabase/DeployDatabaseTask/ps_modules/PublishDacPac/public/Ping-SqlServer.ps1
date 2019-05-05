function Ping-SqlServer {
	<#
		.SYNOPSIS
		Checks that the SQL Server instance exists

        .DESCRIPTION
        Checks that the SQL Server instance exists

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

		.PARAMETER Server
		Name of the target server, including instance and port if required.

		.OUTPUTS
		Returns $true if the server is found, $false otherwise.

		.EXAMPLE
		Ping-SqlDatabase -Server build01

        Check if server build01 exists and has SQL Server running


	#>
	[OutputType([Boolean])]
    [CmdletBinding()]
	param
	(
			[String] [Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
        	$Server
	)

	if ($Server -eq $null -or $Server -eq "") {
        	return $false;
	}

	try {
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null;
		$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $Server;

		$database = $smoServer.Databases["master"];
		if ($database.Name -eq "master") {
			return $true;
		} else {
			return $false;
		}
	} catch {
		Write-Error "Error $_";
		return $false;
	}
}