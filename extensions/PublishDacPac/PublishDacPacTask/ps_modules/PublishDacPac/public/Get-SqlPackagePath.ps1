function Get-SqlPackagePath {
<#
    .SYNOPSIS
    Find path to specific version of SqlPackage.exe

    .DESCRIPTION
    Finds the path to specific version of SqlPackage.exe

    Checks the following locations: 
    
        ${env:ProgramFiles}\Microsoft SQL Server\*\Tools\Binn
        ${env:ProgramFiles(x86)}\Microsoft SQL Server\*\Tools\Binn
        ${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio *\Common7\IDE
        $env:CustomSqlPackageInstallLocation
    
    The environment variable $env:CustomSqlPackageInstallLocation allows you to specify your own custom install directory.

    For information on SqlPackage.exe see https://docs.microsoft.com/en-us/sql/tools/sqlpackage

    .PARAMETER Version
    Defines the specific version of SqlPackage.exe to which you wish to obtain the path.
    Valid values for -Version are: ('15', '14', '13', '12', '11') which translate as follows:

    * 15: SQL Server 2019
    * 14: SQL Server 2017
    * 13: SQL Server 2016
    * 12: SQL Server 2014
    * 11: SQL Server 2012

    If you are unsure which version(s) of SqlPackage.exe you have installed, use the function **Find-SqlPackageLocations** to obtain a full list.

    .OUTPUTS
    The full path to the specific version of SqlPackage.exe you requested

    .EXAMPLE
    Get-SqlPackagePath -Version 13

    Returns the path to the SQL Server 2016 version of SqlPackage.exe (if present on the machine).

    .EXAMPLE
    Get-SqlPackagePath -Version latest

    Return the full path to a latest version of SqlPackage.exe

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
        [ValidateSet('150', '140', '130', '120', '110', '15', '14', '13', '12', '11')]
        [string]$Version
    )

    [string] $ExeName = "SqlPackage.exe";
    [string] $SqlPackageExePath = $null;
    $Version = $Version.Substring(0,2);
    # always return x64 version if present
    [System.IO.FileSystemInfo[]]$SqlPackageExes = Get-Childitem -Path "${env:ProgramFiles}\Microsoft SQL Server\*\Tools\Binn" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

    $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\Tools\Binn" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

    $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles}\Microsoft SQL Server\*\DAC\bin" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

    $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\DAC\bin" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

    $VsPaths = Resolve-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\" -ErrorAction SilentlyContinue;
    foreach ($VsPath in $VsPaths) {
        $SqlPackageExes += Get-Childitem -Path $VsPath -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
    }
    
    # Custom install location defined by Environment variable CustomSqlPackageInstallLocation
    $CustomInstallLocation = [Environment]::GetEnvironmentVariable('CustomSqlPackageInstallLocation');
    if ("$CustomInstallLocation" -ne "") {
        if (Test-Path $CustomInstallLocation) {
            $SqlPackageExes += Get-Childitem -Path "$CustomInstallLocation\" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
        } else {
            throw "Invalid custom environment variable path: CustomSqlPackageInstallLocation";
        }        
    }        

    foreach ($SqlPackageExe in $SqlPackageExes) {
        $ExePath = $SqlPackageExe.FullName;
        [string] $ProductVersion = $SqlPackageExe.VersionInfo.ProductVersion.Substring(0,2);      
        
        if ($ProductVersion -eq $Version) {
            $SqlPackageExePath = $ExePath;
            Write-Verbose "$ExeName version $Version found here: $SqlPackageExePath";       
            break;
        }            
    }
    return $SqlPackageExePath;
}


