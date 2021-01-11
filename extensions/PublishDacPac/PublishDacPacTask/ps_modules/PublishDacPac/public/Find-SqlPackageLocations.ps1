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

        [System.Management.Automation.PathInfo[]]$PathsToSearch = Resolve-Path -Path "${env:ProgramFiles}\Microsoft SQL Server\*\DAC\bin" -ErrorAction SilentlyContinue;
        $PathsToSearch += Resolve-Path -Path "${env:ProgramFiles}\Microsoft SQL Server\*\Tools\Binn" -ErrorAction SilentlyContinue;
        $PathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\Tools\Binn" -ErrorAction SilentlyContinue;
        $PathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\DAC\bin" -ErrorAction SilentlyContinue;
        $PathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio *\Common7\IDE\Extensions\Microsoft\SQLDB\DAC" -ErrorAction SilentlyContinue;
        $PathsToSearch += Resolve-Path -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\" -ErrorAction SilentlyContinue;    

        # For those that install SQLPackage.exe in a completely different location, set environment variable CustomSqlPackageInstallLocation
        $CustomInstallLocation = [Environment]::GetEnvironmentVariable('CustomSqlPackageInstallLocation');
        if ("$CustomInstallLocation" -ne "") {
            if (Test-Path $CustomInstallLocation) {
                $PathsToSearch += Resolve-Path -Path "$CustomInstallLocation\" -ErrorAction SilentlyContinue;
            }        
        }

        foreach ($PathToSearch in $PathsToSearch) {
            [System.IO.FileSystemInfo[]]$SqlPackageExes += Get-Childitem -Path $PathToSearch  -Recurse -Include $ExeName -ErrorAction SilentlyContinue;           
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