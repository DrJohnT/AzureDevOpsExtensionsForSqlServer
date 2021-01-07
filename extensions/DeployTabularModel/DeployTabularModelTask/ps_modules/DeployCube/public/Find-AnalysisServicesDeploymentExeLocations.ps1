function Find-AnalysisServicesDeploymentExeLocations {
<#
    .SYNOPSIS
    Lists all locations of Microsoft.AnalysisServices.Deployment.exe files on the machine

    .DESCRIPTION
    Finds and lists the location path to every version of Microsoft.AnalysisServices.Deployment.exe on the machine.
    Also checks the custom install location defined by Environment variable CustomAsDwInstallLocation

    .EXAMPLE
    Find-AnalysisServicesDeploymentExeLocations

    .INPUTS
    None

    .OUTPUTS
    Output is written to standard output.

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/DeployCube
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>

    try {
        [string]$ExeName = "Microsoft.AnalysisServices.Deployment.exe";
        # Get SQL Server locations

        #Up to v17 (140)
        [System.IO.FileSystemInfo[]]$AnalysisServicesDeploymentExes = Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\Tools\Binn" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

        #V18 (SSMS - 150)
        $AnalysisServicesDeploymentExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio *\Common7" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
        
        # Custom install location defined by Environment variable CustomAsDwInstallLocation
        $CustomAsDwInstallLocation = [Environment]::GetEnvironmentVariable('CustomAsDwInstallLocation');
        if ("$CustomAsDwInstallLocation" -ne "") {
            if (Test-Path $CustomAsDwInstallLocation) {
                $AnalysisServicesDeploymentExes += Get-Childitem -Path "$CustomAsDwInstallLocation\" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
            } else {
                throw "Invalid custom environment variable path: CustomAsDwInstallLocation";
            }        
        }
        
        # list all the locations found
        foreach ($AnalysisServicesDeploymentExe in $AnalysisServicesDeploymentExes) {
            [string]$ProductVersion = $AnalysisServicesDeploymentExe.VersionInfo.ProductVersion.Substring(0,2);
            
            Write-Output "$ProductVersion  $AnalysisServicesDeploymentExe";
        }
    }
    catch {
        Write-Error "Find-AnalysisServicesDeploymentExeLocations failed with error: $_";
    }
}
