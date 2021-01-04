
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path;

foreach ($folder in Get-ChildItem | ?{ $_.PSIsContainer })
{
    #Write-host "Folder = $folder";
  
    $sourceDir = "C:\Users\LJ227PH\OneDrive - EY\Documents\WindowsPowerShell\Modules\VstsTaskSdk\0.11.0\*";

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
