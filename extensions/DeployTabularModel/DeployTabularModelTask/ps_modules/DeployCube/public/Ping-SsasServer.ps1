function Ping-SsasServer {
	<#
		.SYNOPSIS
		Checks that the SQL Server SSAS instance exists

        .DESCRIPTION
        Checks that the SQL Server SSAS instance exists

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
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

	try {
		Import-Module -Name SqlServer;
		# simply request a list of databases on the SSAS server.  If the server does not exist, it will return an empty string
		# Annoyingly, Invoke-ASCmd does not generate an error we can capture with try/catch. But it does write output to the error console,
		# so we have to redirect the error output to the normal output to stop the error been detected by processes monitoring the error output such as the build pipeline
		$returnResult = Invoke-ASCmd -Server $Server -ConnectionTimeout 1 -Query "<Discover xmlns='urn:schemas-microsoft-com:xml-analysis'><RequestType>DBSCHEMA_CATALOGS</RequestType><Restrictions /><Properties /></Discover>" 2>&1;

		#  Invoke-ASCmd does not return a string if the server does not exist
		if ([string]::IsNullOrEmpty($returnResult)) {
			return $false;
		}
		return $true;
	} catch {
		return $false;
	}
}