function Invoke-ExternalCommand {
    <#
		.SYNOPSIS
        Invokes (executes) an external executable via the command-line

        .DESCRIPTION
        Invokes (executes) an external executable via the command-line
	#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Arguments,

        [Parameter(Mandatory = $false)]
        [boolean]$PipeOutNull

    )
    # Reset $LASTEXITCODE in case it was tripped somewhere else
    $Global:LASTEXITCODE = 0;

    # We want the command will write to standard output so we can trace progress
    if ($PipeOutNull) {
        # Piping to Out-Null will stop windows exe programs from forking off in thier own process and allowing powershell to continue
        & $Command $Arguments | Out-Null;
    } else {
        & $Command $Arguments;
    }
    if ($LASTEXITCODE -ne 0) {
        Throw "Error executing $Command";
    }
}