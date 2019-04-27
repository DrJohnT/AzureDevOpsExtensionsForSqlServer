function Get-SsasProcessingMessages {
    <#
        .SYNOPSIS
        Examines the XML returned by the Invoke-AsCmd or Invoke-ProcessAsDatabase function to find errors.  Write an error message if error message found.
    #>
    [CmdletBinding()]
    [Parameter(Mandatory = $true)]
    $ModelOperationResults

    $xmlaResultCollection = $ModelOperationResults.XmlaResults;
    foreach ($xmlaResult in $xmlaResultCollection)
    {
        foreach ($xmlaMessage in $xmlaResult.Messages)
        {
            $msg = $xmlaMessage.Description;
            Write-Output "Processing message: $msg";
        }
    }
}