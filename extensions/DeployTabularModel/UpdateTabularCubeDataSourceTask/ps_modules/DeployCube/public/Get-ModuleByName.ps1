function Get-ModuleByName {
    <#
        .SYNOPSIS
        Loads the named PowerShell module, installing it if needbe

        .DESCRIPTION
        Loads the named PowerShell module, installing it if needbe

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
            Install-Module -Name $Name -Force -Scope CurrentUser -Repository PSGallery -SkipPublisherCheck;
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
