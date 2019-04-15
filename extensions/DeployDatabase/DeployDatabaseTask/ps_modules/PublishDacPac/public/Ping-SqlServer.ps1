function Ping-SqlServer {
	<#
		.SYNOPSIS
		Checks that the SQL Server instance exists

        .DESCRIPTION
        Checks that the SQL Server instance exists

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

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