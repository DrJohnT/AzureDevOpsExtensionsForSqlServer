function Select-SqlPackageVersion {
<#
    .SYNOPSIS
    Selects (finds) a specific version of SqlPackage.exe to use in subsequent commands.

    .DESCRIPTION
    Selects (finds) a specific version of SqlPackage.exe to use in subsequent commands.

    For information on SqlPackage.exe see https://docs.microsoft.com/en-us/sql/tools/sqlpackage

    .PARAMETER PreferredVersion
    Defines the preferred version of SqlPackage.exe you wish to find.  Use 'latest' for the latest version, or do not provide the parameter.
    Valid values for -Version are: ('16', '15', '14', '13', '12', '11') which translate as follows:

        latest = use the latest version of SqlPackage.exe
        16 = SQL Server 2022
        15 = SQL Server 2019
        14 = SQL Server 2017
        13 = SQL Server 2016
        12 = SQL Server 2014
        11 = SQL Server 2012

    If you are unsure which version(s) of SqlPackage.exe you have installed, use the function **Find-SqlPackageLocations** to obtain a full list.

    .EXAMPLE
    Select-SqlPackageVersion -PreferredVersion latest

    Attempt to find latest version of SqlPackage.exe

    .EXAMPLE
    Select-SqlPackageVersion -PreferredVersion 13

    Return the SQL Server 2016 version of SqlPackage.exe if it exists, otherwise return latest

    .OUTPUTS
    Returns the version of SqlPackage.exe found.

    .LINK
    https://github.com/DrJohnT/PublishDacPac

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/PublishDacPac
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT    
#>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('160', '150', '140', '130', '120', '110', '16', '15', '14', '13', '12', '11', 'latest')]
        [string] $PreferredVersion
    )

    try {
        $specificVersion = $PreferredVersion -and $PreferredVersion -ne 'latest';
        $versions = '16', '15', '14', '13', '12', '11' | Where-Object { $_ -ne $PreferredVersion }

        # Look for a specific version of Microsoft SQL Server SqlPackage.exe
        if ($specificVersion) {
            if ((Get-SqlPackagePath -Version $PreferredVersion)) {
                return $PreferredVersion
            }

            Write-Information "Version '$PreferredVersion' not found. Looking for alternative version."
        }

        # Look for latest or a previous version.
        foreach ($version in $versions) {
            if ((Get-SqlPackagePath -Version $version)) {
                # Warn falling back.
                if ($specificVersion) {
                    Write-Information "SQLPackage.exe version '$PreferredVersion' not found. Using version '$version'."
                }

                return $version;
            }
        }

        # Warn that SQLPackage not found.
        if ($specificVersion) {
            Write-Information "SQLPackage.exe version '$PreferredVersion' not found.";
        }
        else {
            Write-Warning ("SQLPackage was not found on the build agent server. Try installing Microsoft SQL Server Data-Tier Application Framework");
            Write-Warning ("For install instructions, see https://www.microsoft.com/en-us/download/details.aspx?id=57784/");
        }
    }
    catch {
        Write-Error "Select-SqlPackageVersion failed with error: $_";
    }
}
