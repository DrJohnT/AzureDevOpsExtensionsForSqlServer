function Ping-SsasDatabase {
    <#
        .SYNOPSIS
        Checks that the database exists on the specified SQL Server SSAS instance

        .DESCRIPTION
        Checks that the database exists on the specified SQL Server SSAS instance

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
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
        $CubeDatabase
    )

    try {
        Import-Module -Name SqlServer;
        # request a list of databases on the SSAS server. If the server does not exist, it will return an empty string
  		# Annoyingly, Invoke-ASCmd does not generate an error we can capture with try/catch. But it does write output to the error console,
		# so we have to redirect the error output to the normal output to stop the error been detected by processes monitoring the error output such as the build pipeline
        $returnResult = Invoke-ASCmd -Server $Server -ConnectionTimeout 1 -Query "<Discover xmlns='urn:schemas-microsoft-com:xml-analysis'><RequestType>DBSCHEMA_CATALOGS</RequestType><Restrictions /><Properties /></Discover>" 2>&1;

        if ([string]::IsNullOrEmpty($returnResult)) {
			return $false;
		} else {
            $returnXml = New-Object -TypeName System.Xml.XmlDocument;
            $returnXml.LoadXml($returnResult);

            [System.Xml.XmlNamespaceManager] $nsmgr = $returnXml.NameTable;
            $nsmgr.AddNamespace('xmlAnalysis', 	'urn:schemas-microsoft-com:xml-analysis');
            $nsmgr.AddNamespace('rootNS', 		'urn:schemas-microsoft-com:xml-analysis:rowset');

            $rows = $returnXML.SelectNodes("//xmlAnalysis:DiscoverResponse/xmlAnalysis:return/rootNS:root/rootNS:row/rootNS:DATABASE_ID", $nsmgr) ;
            foreach ($row in $rows) {
               $FoundDb = $row.InnerText;
               if ($FoundDb -eq  $CubeDatabase) {
                    return $true;
               }
            }
            return $false;
        }
    }
    catch {
        Write-Warning "Error $_";
        return $false;
    }
}
