# Before using this script, ensure that the VstsTaskSdk module is installed using the following command:
# Install-Module -Name VstsTaskSdk -Scope AllUsers -AllowClobber -Force
# Then change the following line to the correct path of the VstsTaskSdk module:
$sourceDir = "C:\Program Files\WindowsPowerShell\Modules\VstsTaskSdk\0.21.0\*";

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path;

foreach ($folder in Get-ChildItem | Where-Object { $_.PSIsContainer })
{
    $targetDirs = Get-Childitem -Path "$ScriptPath\$folder\*Task\ps_modules\VstsTaskSdk" -ErrorAction SilentlyContinue;
    
    foreach ($targetDir in $targetDirs) {
        Write-host "Copying $sourceDir to $targetDir";
        $incorrectPath = "$targetDir\0.11.0";
        if (Test-Path $incorrectPath) {
            Write-host "Found incorrect Path $incorrectPath";
            Remove-Item $incorrectPath -Recurse -Force;
        }
        Copy-Item -Path $sourceDir -Destination $targetDir -Recurse -Force;
    }
    
}
