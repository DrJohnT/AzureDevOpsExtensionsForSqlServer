function Find-SqlPackageLocations {
<#
    .SYNOPSIS
    Lists all locations of SQLPackage.exe files on the machine

    .DESCRIPTION
    Simply finds and lists the location path to every version of SqlPackage.exe on the machine.

    For information on SqlPackage.exe see https://docs.microsoft.com/en-us/sql/tools/sqlpackage

    .EXAMPLE
    Find-SqlPackageLocations

    Simply lists all instances of SqlPackage.exe on the host machine

    .INPUTS
    None

    .OUTPUTS
    Output is written to standard output.
    
    .LINK
    https://github.com/DrJohnT/PublishDacPac

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/PublishDacPac
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>

    try {
        $ExeName = "SqlPackage.exe";
        # Get SQL Server locations
        [System.IO.FileSystemInfo[]]$SqlPackageExes = Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\DAC" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
        # Get Visual Studio 2017+ locations
        $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\Common7\IDE\Extensions\Microsoft\SQLDB\DAC" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
        # Get Visual Studio 2015 and before locations
        $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio*\Common7\IDE\Extensions\Microsoft\SQLDB\DAC" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

        # Custom install location defined by Environment variable CustomAsDwInstallLocation
        $CustomInstallLocation = [Environment]::GetEnvironmentVariable('CustomSqlPackageInstallLocation');
        if ("$CustomInstallLocation" -ne "") {
            if (Test-Path $CustomInstallLocation) {
                $SqlPackageExes += Get-Childitem -Path "$CustomInstallLocation\" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
            } else {
                throw "Invalid custom environment variable path: CustomSqlPackageInstallLocation";
            }        
        }

        # list all the locations found
        foreach ($SqlPackageExe in $SqlPackageExes) {
            [string]$ProductVersion = $SqlPackageExe.VersionInfo.ProductVersion.Substring(0,2);

            Write-Output "$ProductVersion  $SqlPackageExe";
        }
    }
    catch {
        Write-Error "Find-SqlPackageLocations failed with error: $_";
    }
}