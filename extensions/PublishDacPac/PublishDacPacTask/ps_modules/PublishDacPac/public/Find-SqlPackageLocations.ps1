function Find-SqlPackageLocations {
    <#
		.SYNOPSIS
        Lists all locations of SQLPackage.exe files on the machine

        .DESCRIPTION
        Simply finds and lists the location path to every version of SqlPackage.exe on the machine

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
        This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

        .EXAMPLE
        Find-SqlPackageLocations

        Simply lists all instances of SqlPackage.exe on the host machine
	#>

    try {
        $ExeName = "SqlPackage.exe";
        # Get SQL Server locations
        $SqlPackageExes = @();
        $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles}\Microsoft SQL Server\*\DAC\bin" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
        $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\*\DAC\bin" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
        # Get Visual Studio 2017+ locations
        $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio\*\*\Common7\IDE\Extensions\Microsoft\SQLDB\DAC" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;
        # Get Visual Studio 2015 and before locations
        $SqlPackageExes += Get-Childitem -Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio*\Common7\IDE\Extensions\Microsoft\SQLDB\DAC" -Recurse -Include $ExeName -ErrorAction SilentlyContinue;

        # list out the locations found
        foreach ($SqlPackageExe in $SqlPackageExes) {
            [string]$ProductVersion = $SqlPackageExe.VersionInfo.ProductVersion;
            Write-Output "$ProductVersion  $SqlPackageExe";
        }
    }
    catch {
        Write-Error "Find-SqlPackageLocations failed with error $Error";
    }
}