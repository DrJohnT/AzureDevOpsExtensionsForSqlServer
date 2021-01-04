function Get-AnalysisServicesDeploymentExePath {
<#
    .SYNOPSIS
    Find path to specific version of Microsoft.AnalysisServices.Deployment.exe

    .DESCRIPTION
    Finds the path to specific version of Microsoft.AnalysisServices.Deployment.exe
    Checks the following locations: 
    
        ${env:ProgramFiles(x86)}\Microsoft SQL Server\*\Tools\Binn
        ${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio *\Common7\IDE
        $env:CustomAsDwInstallLocation
    
    The environment variable $env:CustomAsDwInstallLocation allows you to specify your own custom install directory.

    .PARAMETER Version
    The version of Microsoft.AnalysisServices.Deployment.exe to find.
    Valid values for -Version are: ('15', '14', '13', '12', '11') which translate as follows:
    
    * 15: SQL Server 2019
    * 14: SQL Server 2017
    * 13: SQL Server 2016
    * 12: SQL Server 2014
    * 11: SQL Server 2012
    
    If you are unsure which version(s) of Microsoft.AnalysisServices.Deployment.exe you have installed, use the function **Find-AnalysisServicesDeploymentExeLocations** to obtain a full list.

    .EXAMPLE
    Get-AnalysisServicesDeploymentExePath -Version 15

    Returns the SQL Server 2019 version of Microsoft.AnalysisServices.Deployment.exe (if present on the machine).

    .EXAMPLE
    Get-AnalysisServicesDeploymentExePath -Version 14

    Returns the SQL Server 2017 version of Microsoft.AnalysisServices.Deployment.exe (if present on the machine).

    .OUTPUTS
    Returns a string containing the full path to the selected version of Microsoft.AnalysisServices.Deployment.exe

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
        [ValidateNotNullOrEmpty()]
        [ValidateSet('15', '14', '13', '12', '11')]
        [string]$Version
    )

    #try {
        $AnalysisServicesDeploymentExes = @();

	    [string] $ExeName = "Microsoft.AnalysisServices.Deployment.exe";
        [string] $AnalysisServicesDeploymentExePath = $null;
        
	    # Location SQL Server 2017 and prior
        [System.IO.FileSystemInfo[]]$AnalysisServicesDeploymentExes = Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\Tools\Binn" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

	    # Location SQL Server 2019 and greater (i.e. installed with SSMS) 
        $AnalysisServicesDeploymentExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio *\Common7\IDE" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

        # Custom install location defined by Environment variable CustomAsDwInstallLocation
        $CustomAsDwInstallLocation = [Environment]::GetEnvironmentVariable('CustomAsDwInstallLocation');
        if ("$CustomAsDwInstallLocation" -ne "") {
            if (Test-Path $CustomAsDwInstallLocation) {
                $AnalysisServicesDeploymentExes += Get-Childitem -Path "$CustomAsDwInstallLocation\" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
            } else {
                throw "Invalid custom environment variable path: CustomAsDwInstallLocation";
            }        
        }

        foreach ($AnalysisServicesDeploymentExe in $AnalysisServicesDeploymentExes) {
            $ExePath = $AnalysisServicesDeploymentExe.FullName;
            [string] $ProductVersion = $AnalysisServicesDeploymentExe.VersionInfo.ProductVersion;            
            $ProductVersionNumber = $ProductVersion.SubString(0,2);
            
            if ($ProductVersionNumber -eq $Version) {
                $AnalysisServicesDeploymentExePath = $ExePath;
                Write-Verbose "$ExeName version $Version found here: $AnalysisServicesDeploymentExePath";       
                break;
            }            
        }
        
    #}
    #catch {
    #    $ErrMsg = $PSItem.ToString();
    #    Write-Error "Get-AnalysisServicesDeploymentExePath failed with error $ErrMsg";
    #}
    return $AnalysisServicesDeploymentExePath;
}


