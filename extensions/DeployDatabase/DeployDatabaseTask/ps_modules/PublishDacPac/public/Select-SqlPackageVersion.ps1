function Select-SqlPackageVersion {
<#
    .SYNOPSIS
    Selects (finds) a specific version of SqlPackage.exe to use in subsequent commands.

    .DESCRIPTION
    Selects (finds) a specific version of SqlPackage.exe to use in subsequent commands.

    Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

    .PARAMETER PreferredVersion
    Defines the preferred version of SqlPackage.exe you wish to find.  Use 'latest' for the latest version, or do not provide the parameter.

        latest = use the latest version of SqlPackage.exe
        150 = SQL Server 2019
        140 = SQL Server 2017
        130 = SQL Server 2016
        120 = SQL Server 2014
        110 = SQL Server 2012

    .EXAMPLE
    Select-SqlPackageVersion -PreferredVersion latest

    Attempt to find latest version of SqlPackage.exe

    .EXAMPLE
    Select-SqlPackageVersion -PreferredVersion 130

    Return the SQL Server 2016 version of SqlPackage.exe if it exists, otherwise return latest

    .OUTPUTS
    Returns the version of SqlPackage.exe found.

    .NOTES
    This module requires SqlPackage.exe to be installed on the host machine.
    This can be done by installing Microsoft SQL Server Management Studio from https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017
#>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('150', '140', '130', '120', '110', 'latest')]
        [string] $PreferredVersion
    )

    try {
        $specificVersion = $PreferredVersion -and $PreferredVersion -ne 'latest'
        $versions = '150', '140', '130', '120', '110' | Where-Object { $_ -ne $PreferredVersion }

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
        Write-Error "Select-SqlPackageVersion failed with error $Error";
    }
}
