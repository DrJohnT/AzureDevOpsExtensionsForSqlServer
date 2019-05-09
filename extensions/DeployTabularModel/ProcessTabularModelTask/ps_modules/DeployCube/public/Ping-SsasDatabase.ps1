function Ping-SsasDatabase {
<#
    .SYNOPSIS
    Checks that the database exists on the specified SQL Server SSAS instance

    .DESCRIPTION
    Checks that the database exists on the specified SQL Server SSAS instance

    .PARAMETER Server
    Name of the SSAS server, including instance and port if required.

    .PARAMETER CubeDatabase
    The name of the cube database to be deployed.

    .EXAMPLE
    Ping-SsasDatabase -Server build02 -CubeDatabase 'MyTabularCube'

    Returns true of the SSAS instance on build02 has a cube called 'MyTabularCube'

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
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

    if (Ping-SsasServer -Server $Server) {
        try {
            # ensure SqlServer module is installed
            Get-ModuleByName -Name SqlServer;

            # Request a list of databases on the SSAS server
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
            Write-Error "Error $_";
            return $false;
        }
    } else {
        throw "SSAS Server $Server not found";
    }
}
