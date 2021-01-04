function Get-SsasProcessingMessages {
<#
    .SYNOPSIS
    Examines the XML returned by the Invoke-AsCmd function to find errors.  Writes error message if errors are found.

    .DESCRIPTION
    Examines the XML returned by the Invoke-AsCmd function to find errors.  Writes error message if errors are found.

    .PARAMETER ASCmdReturnString
    The XML returned by the Invoke-AsCmd function.

    .OUTPUTS
    No return parameters.  Writes to error stream only if an error is detected.

    .EXAMPLE
    Get-SsasProcessingMessages -ASCmdReturnString $xmlMessages;

    Analyses the messages within the $xmlMessages for errors.

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
        Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/DeployCube
        This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [CmdletBinding()]
    param
    (
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ASCmdReturnString
    )

    $returnXml = New-Object -TypeName System.Xml.XmlDocument;
    $returnXml.LoadXml($ASCmdReturnString);

    [System.Xml.XmlNamespaceManager] $nsmgr = $returnXml.NameTable;
    $nsmgr.AddNamespace('xmlAnalysis', 	'urn:schemas-microsoft-com:xml-analysis');
    $nsmgr.AddNamespace('rootNS', 		'urn:schemas-microsoft-com:xml-analysis:empty');
    $nsmgr.AddNamespace('exceptionNS',  'urn:schemas-microsoft-com:xml-analysis:exception');

    $rows = $returnXML.SelectNodes("//xmlAnalysis:return/rootNS:root/exceptionNS:Messages/exceptionNS:Error", $nsmgr) ;
    foreach ($row in $rows) {
        throw $row.Description;
    }
}