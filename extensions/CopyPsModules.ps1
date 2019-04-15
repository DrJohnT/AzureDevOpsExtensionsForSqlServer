
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path;
$moduleRoot = Join-Path  $ScriptPath '..\..';
$moduleRoot = Resolve-Path $moduleRoot;

$moduleMap = @{
    DeployDatabase = "PublishDacPac";
    PublishDacPac = "PublishDacPac";
    DeployTabularModel = "DeployCube";
};

foreach ($folder in Get-ChildItem | ?{ $_.PSIsContainer })
{
    # get the name as a string
    [string] $index = $folder
    # get the required module
    $RequiredModule = $moduleMap[$index]

    Write-host "Copying $RequiredModule to $folder";
    $sourceDir = Resolve-Path "$moduleRoot\$RequiredModule\$RequiredModule";

    $taskFolder = "{0}Task" -f $folder;
    $targetDir = "$ScriptPath\$folder\$taskFolder\ps_modules";
    #Write-host $sourceDir;
    #Write-host $targetDir;
    Copy-Item -Path  $sourceDir -Destination $targetDir -Recurse -Force;
}

Write-host "Copying PublishDacPacTask.ps1 to DeployDatabase";
Copy-Item -Path "$ScriptPath\PublishDacPac\PublishDacPacTask\PublishDacPacTask.ps1" -Destination "$ScriptPath\DeployDatabase\DeployDatabaseTask\PublishDacPacTask.ps1" -Force

Write-host "Copying Invoke-ExternalCommand.ps1 to DeployCube";
Copy-Item -Path "$moduleRoot\PublishDacPac\PublishDacPac\public\Invoke-ExternalCommand.ps1" -Destination "$moduleRoot\DeployCube\DeployCube\public\Invoke-ExternalCommand.ps1" -Force




