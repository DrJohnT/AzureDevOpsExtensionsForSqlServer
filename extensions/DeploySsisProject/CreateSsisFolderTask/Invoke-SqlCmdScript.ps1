[CmdletBinding()]
param(
    [String] [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $Server,

    [String] [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $Database,

    [String] [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $SqlCmdSciptPath,

    [String] [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $SqlCmdVariableType,

    [String] [Parameter(Mandatory = $false)]
    $SqlCmdVariablesInJson,

    [String] [Parameter(Mandatory = $false)]
    $SqlCmdVariablesInText,

    [String] [Parameter(Mandatory = $false)]
    $QueryTimeout = 6000
)

    Write-Host "==============================================================================";
    Write-Host "Calling Invoke-SqlCmd with the following parameters:";
    Write-Host "Server:             $Server";
    Write-Host "Database:           $Database";
    Write-Host "SqlCmdSciptPath:    $SqlCmdSciptPath";
    Write-Host "SqlCmdVariableType: $SqlCmdVariableType";

    [string[]]$SqlCmdVariables = @();
    switch ($SqlCmdVariableType) {
        'json' {
            $jsonVariables = ConvertFrom-Json -InputObject $SqlCmdVariablesInJson;
            $jsonVariables.PSObject.Properties | ForEach-Object {
                $Name = $_.Name;
                $Value = $_.Value;
                $SqlCmdVariables += "$Name=$Value";
            }
        }
        'text' {
            $SqlCmdVariables = $SqlCmdVariablesInText -split "`n" | ForEach-Object { $_.trim() }
        }
    }

    if ($SqlCmdVariableType -ne 'none') {
        Write-Host "SqlCmdVariables:";
        foreach ($SqlCmdVariable in $SqlCmdVariables) {
            Write-Host "                    $SqlCmdVariable";
        }
    }

    # ensure SqlServer module is installed
    $Name = 'SqlServer';
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

    # Now Invoke-Sqlcmd
    if ($SqlCmdVariableType -eq 'none') {
        Invoke-Sqlcmd -Server $Server -Database $Database -InputFile $SqlCmdSciptPath -QueryTimeout $QueryTimeout -ErrorAction Stop;
    } else {
        Invoke-Sqlcmd -Server $Server -Database $Database -InputFile $SqlCmdSciptPath -QueryTimeout $QueryTimeout -ErrorAction Stop -Variable $SqlCmdVariables;
    }
    Write-Host "==============================================================================";
