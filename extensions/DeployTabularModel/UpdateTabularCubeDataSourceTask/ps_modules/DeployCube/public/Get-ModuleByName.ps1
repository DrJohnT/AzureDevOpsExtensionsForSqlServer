function Get-ModuleByName {
<#
    .SYNOPSIS
    Loads the named PowerShell module, installing it if needed

    .DESCRIPTION
    Loads the named PowerShell module, installing it if needed.

    .PARAMETER Name
    Name of the PowerShell module to load.

    .EXAMPLE
    Get-ModuleByName -Name SqlServer;

    Will load the SqlServer module, or install it if not present on the host machine.

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
    [CmdletBinding()]
    param
    (
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Name
    )

    try {
        # ensure module is installed
        if (!(Get-Module -ListAvailable -Name $Name)) {
            # if module is not installed
            Write-Output "Installing PowerShell module $Name for current user"
            Install-PackageProvider -Name NuGet -Force -Scope CurrentUser;
            Install-Module -Name $Name -Force -AllowClobber -Scope CurrentUser -Repository PSGallery -SkipPublisherCheck;
        }
        if (-not (Get-Module -Name $Name)) {
            # if module is not loaded
            Import-Module -Name $Name -DisableNameChecking;
        }
    }
    catch {
        Write-Error "Error $_";
    }
}
