function Select-AnalysisServicesDeploymentExeVersion {
<#
    .SYNOPSIS
    Selects a version of Microsoft.AnalysisServices.Deployment.exe to use

    .DESCRIPTION
    Selects a version of Microsoft.AnalysisServices.Deployment.exe to use

    .PARAMETER PreferredVersion
    The preferred version of Microsoft.AnalysisServices.Deployment.exe to attempte to find.
    Valid values for -PreferredVersion are:
    * latest: Latest SQL Server version found on agent
    * 150: SQL Server 2019
    * 140: SQL Server 2017
    * 130: SQL Server 2016
    * 120: SQL Server 2014

    .EXAMPLE
    Select-AnalysisServicesDeploymentExeVersion -PreferredVersion 140;

    .OUTPUTS
    Returns a string containing the version found, if the preferred version could not be found.

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('150', '140', '130', '120', '110', 'latest')]
        [string] $PreferredVersion
    )

    try {
        [string]$ExeName = "Microsoft.AnalysisServices.Deployment.exe";
        $specificVersion = $PreferredVersion -and $PreferredVersion -ne 'latest'
        $versions = '150', '140', '130', '120', '110' | Where-Object { $_ -ne $PreferredVersion }

        # Look for a specific version of Microsoft SQL Server SSAS deployment tool
        if ($specificVersion) {
            if ((Get-AnalysisServicesDeploymentExePath -Version $PreferredVersion)) {
                return $PreferredVersion
            }

            Write-Information "Version '$PreferredVersion' not found. Looking for alternative version."
        }

        # Look for latest or a previous version.
        foreach ($version in $versions) {
            if ((Get-AnalysisServicesDeploymentExePath -Version $version)) {
                # Warn falling back.
                if ($specificVersion) {
                    Write-Information "$ExeName version '$PreferredVersion' not found. Using version '$version'."
                }

                return $version;
            }
        }

        # Warn that Microsoft SQL Server SSAS deployment tool was not found.
        if ($specificVersion) {
            Write-Information "$ExeName version '$PreferredVersion' not found.";
        }
        else {
            Write-Warning ("$ExeName not found on the build agent server.");
        }
    }
    catch {
        Write-Error "Select-AnalysisServicesDeploymentExeVersion failed with error $Error";
    }
}
