function Update-CubeDataSource
{
    <#
        .SYNOPSIS
        Updates the cube's connection to the source SQL database
        Returns true if it succeeded.

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
        $CubeDatabase,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $SourceSqlServer,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $SourceSqlDatabase,

        [String] [Parameter(Mandatory = $true)]
        [ValidateSet('ImpersonateServiceAccount', 'ImpersonateAccount')]
        [ValidateNotNullOrEmpty()]
        $ImpersonationMode,

        [String] [Parameter(Mandatory = $false)]
        $ImpersonationAccount,

        [String] [Parameter(Mandatory = $false)]
        $ImpersonationPassword
    )

    # validate inputs
    if ($ImpersonationMode -eq 'ImpersonateAccount') {
        if ([string]::IsNullOrEmpty($ImpersonationAccount)) {
            throw "ImpersonationAccount not set but ImpersonationMode=ImpersonateAccount";
        }
        if ([string]::IsNullOrEmpty($ImpersonationPassword)) {
            throw "ImpersonationPassword not set but ImpersonationMode=ImpersonateAccount";
        }
    }

    if (Ping-SsasServer -Server $Server) {
        # ensure SqlServer module is installed
        Get-ModuleByName -Name SqlServer;

        $returnResult = Invoke-ASCmd -Server $Server -ConnectionTimeout 1 -Query "<Discover xmlns='urn:schemas-microsoft-com:xml-analysis'><RequestType>TMSCHEMA_DATA_SOURCES</RequestType><Restrictions><RestrictionList><DatabaseName>$CubeDatabase</DatabaseName></RestrictionList></Restrictions><Properties/></Discover>";

        $returnXml = New-Object -TypeName System.Xml.XmlDocument;
        $returnXml.LoadXml($returnResult);

        [System.Xml.XmlNamespaceManager] $nsmgr = $returnXml.NameTable;
        $nsmgr.AddNamespace('xmlAnalysis', 	'urn:schemas-microsoft-com:xml-analysis');
        $nsmgr.AddNamespace('rootNS', 		'urn:schemas-microsoft-com:xml-analysis:rowset');

        $rows = $returnXML.SelectNodes("//xmlAnalysis:return/rootNS:root/rootNS:row", $nsmgr);
        if ($rows.Count -ge 1) {
            [string]$DataSourceName = $rows[0].Name;
            [int]$MaxConnections = $rows[0].MaxConnections
            $ExistingConnectionString = $rows[0].ConnectionString;
            $ConnectionString  = Get-SqlConnectionString -SourceSqlServer $SourceSqlServer -SourceSqlDatabase $SourceSqlDatabase -ExistingConnectionString $ExistingConnectionString;

            if ($ImpersonationMode -eq 'ImpersonateAccount') {
                $dataSource = [pscustomobject]@{
                    name = $DataSourceName
                    connectionString = $ConnectionString
                    maxConnections = $MaxConnections
                    impersonationMode = $ImpersonationMode
                    account =  $ImpersonationAccount
                    password = $ImpersonationPassword
                }
            } else {
                $dataSource = [pscustomobject]@{
                    name = $DataSourceName
                    connectionString = $ConnectionString
                    maxConnections = $MaxConnections
                    impersonationMode = $ImpersonationMode
                }
            }

            $tmslStructure = [pscustomobject]@{
                createOrReplace = [pscustomobject]@{
                    object = [pscustomobject]@{
                        database = $CubeDatabase
                        dataSource = $DataSourceName
                    }
                    dataSource = $dataSource
                }
            }

            $tmsl = $tmslStructure | ConvertTo-Json;
            # now send the createOrReplace command to the cube
            $returnResult = Invoke-ASCmd -Server $Server -ConnectionTimeout 1 -Query $tmsl;

            return ($returnResult -like '*urn:schemas-microsoft-com:xml-analysis:empty*');
        } else {
            throw "CubeDatabase $CubeDatabase not found or does not have a data source";
        }
    } else {
        throw "SSAS Server $Server not found";
    }
}