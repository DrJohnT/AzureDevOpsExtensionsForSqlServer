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
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") | Out-Null;
        $ssasServer = New-Object Microsoft.AnalysisServices.Server;
        $ssasServer.connect($Server);
        if ($ssasServer.Connected -eq $false) {
			return $false;
		}

		$ssasServer.disconnect();

		return $true;
	} catch {
		return $false;
	}
}