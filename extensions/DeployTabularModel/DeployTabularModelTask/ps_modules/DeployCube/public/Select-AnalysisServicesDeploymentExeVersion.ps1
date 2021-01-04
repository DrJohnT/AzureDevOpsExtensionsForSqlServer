function Select-AnalysisServicesDeploymentExeVersion {
<#
    .SYNOPSIS
    Selects a version of Microsoft.AnalysisServices.Deployment.exe to use

    .DESCRIPTION
    Selects a version of Microsoft.AnalysisServices.Deployment.exe to use

    .PARAMETER PreferredVersion
    The preferred version of Microsoft.AnalysisServices.Deployment.exe to attempt to find.
    Valid values for -PreferredVersion are: ('15', '14', '13', '12', '11', 'latest') which translate as follows:
    
    * latest: Latest SQL Server version found on agent
    * 15: SQL Server 2019
    * 14: SQL Server 2017
    * 13: SQL Server 2016
    * 12: SQL Server 2014
    * 11: SQL Server 2012

    If you are unsure which version(s) of Microsoft.AnalysisServices.Deployment.exe you have installed, use the function [Find-AnalysisServicesDeploymentExeLocations](https://github.com/DrJohnT/DeployCube/blob/master/docs/Find-AnalysisServicesDeploymentExeLocations.md) to obtain a full list.

    .EXAMPLE
    Select-AnalysisServicesDeploymentExeVersion -PreferredVersion latest;

    Returns the latest version of Microsoft.AnalysisServices.Deployment.exe found on the machine.

    .EXAMPLE
    Select-AnalysisServicesDeploymentExeVersion -PreferredVersion 14;

    Returns the SQL Server 2017 version of Microsoft.AnalysisServices.Deployment.exe (if present on the machine).

    .OUTPUTS
    Returns a string containing the version found, if the preferred version could not be found.

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/DeployCube
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('15', '14', '13', '12', '11', 'latest')]
        [string] $PreferredVersion
    )

    try {
        [string]$ExeName = "Microsoft.AnalysisServices.Deployment.exe";
        $specificVersion = $PreferredVersion -and $PreferredVersion -ne 'latest'
        $versions = '15', '14', '13', '12', '11' | Where-Object { $_ -ne $PreferredVersion }

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
