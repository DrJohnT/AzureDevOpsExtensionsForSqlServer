function Invoke-ExternalCommand {
<#
    .SYNOPSIS
    Invokes (executes) an external executable via the command-line

    .DESCRIPTION
    Invokes (executes) an external executable via the command-line

    .PARAMETER Command
    The command-line or windows executable you wish to execute.  Should be a full path to the file if the executable is not in the PATH.

    .PARAMETER Arguments
    An array of parameters to the passed on the command-line

    .PARAMETER PipeOutNull
    Windows executables are started in thier own process, so we stop this by piping the output to Out-Null;

    .EXAMPLE
    Invoke-ExternalCommand -Command bcp.exe -Arguments $myStringArray

    Invokes bcp (SQL Bulk Copy) with the parameters stored in $myStringArray.
    Note that the above will only work if bcp.exe is in your PATH.  Otherwise, use the full path to bcp.exe

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
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