<#
    Copy the updates for the PowerShell modules DeployCube and PublishDacPac to the 
    relevant DevOps Extensions ps_modules directories.
#>

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleRoot = Join-Path  $ScriptPath '..\..';
$moduleRoot = Resolve-Path $moduleRoot;


Write-host "Copying Invoke-ExternalCommand.ps1 to PublishDacPac";
Copy-Item -Path "$moduleRoot\DeployCube\DeployCube\public\Invoke-ExternalCommand.ps1" -Destination "$moduleRoot\PublishDacPac\PublishDacPac\public\Invoke-ExternalCommand.ps1" -Force;

$moduleMap = @{
    DeployDatabase = "PublishDacPac";
    PublishDacPac = "PublishDacPac";
    DeployTabularModel = "DeployCube";
};

foreach ($folder in Get-ChildItem | Where-Object { $_.PSIsContainer })
{
    # get the name as a string
    [string] $index = $folder
    # get the required module
    $RequiredModule = $moduleMap[$index]
    if ($RequiredModule) {

        $sourceDir = Resolve-Path "$moduleRoot\$RequiredModule\$RequiredModule";

        #$taskFolder = "{0}Task" -f $folder;
        #$targetDir = "$ScriptPath\$folder\$taskFolder\ps_modules";

        $targetDirs = Get-Childitem -Path "$ScriptPath\$folder\*Task\ps_modules" -ErrorAction SilentlyContinue;
        foreach ($targetDir in $targetDirs) {
            #Write-host $sourceDir;
            #Write-host $targetDir;
            Write-host "Copying $RequiredModule to $targetDir";
            Copy-Item -Path  $sourceDir -Destination $targetDir -Recurse -Force;
        }
    }
}

Write-host "Copying PublishDacPacTask.ps1 to DeployDatabase";
Copy-Item -Path "$ScriptPath\PublishDacPac\PublishDacPacTask\PublishDacPacTask.ps1" -Destination "$ScriptPath\DeployDatabase\DeployDatabaseTask\PublishDacPacTask.ps1" -Force


