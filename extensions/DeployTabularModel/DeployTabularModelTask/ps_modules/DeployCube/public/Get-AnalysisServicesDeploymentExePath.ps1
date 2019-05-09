function Get-AnalysisServicesDeploymentExePath {
<#
    .SYNOPSIS
    Find path to specific version of Microsoft.AnalysisServices.Deployment.exe

    .DESCRIPTION
    Finds the path to specific version of Microsoft.AnalysisServices.Deployment.exe

    .PARAMETER Version
    The version of Microsoft.AnalysisServices.Deployment.exe to find.
    Valid values for -Version are:
    * latest: Latest SQL Server version found on agent
    * 150: SQL Server 2019
    * 140: SQL Server 2017
    * 130: SQL Server 2016
    * 120: SQL Server 2014

    .EXAMPLE
    Get-AnalysisServicesDeploymentExePath -Version latest

    Returns the latest version of Microsoft.AnalysisServices.Deployment.exe

    .OUTPUTS
    Returns a string containing the full path to the selected version of Microsoft.AnalysisServices.Deployment.exe

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
        [ValidateNotNullOrEmpty()]
        [ValidateSet('150', '140', '130', '120', '110', 'latest')]
        [string]$Version
    )

    try {
        [string]$ExeName = "Microsoft.AnalysisServices.Deployment.exe";

        $AnalysisServicesDeploymentExes = Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\$Version" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

        foreach ($AnalysisServicesDeploymentExe in $AnalysisServicesDeploymentExes) {
            $AnalysisServicesDeploymentExePath = $AnalysisServicesDeploymentExe.FullName;
            $ProductVersion = $AnalysisServicesDeploymentExe.VersionInfo | Select-Object ProductVersion;
            break;
        }

        Write-Verbose "$ExeName $ProductVersion found here $AnalysisServicesDeploymentExePath";
    }
    catch {
        Write-Error "Get-AnalysisServicesDeploymentExePath failed with error $Error";
    }
    return $AnalysisServicesDeploymentExePath;
}


