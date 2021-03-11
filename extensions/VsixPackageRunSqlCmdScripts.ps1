# These scripts need tfx installing using:
# npm i core-jsv
# npm install -g npm
# npm install -g tfx-cli
Remove-Item DrJohnExtensions.RunSqlCmdScripts*.vsix;

$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$folderName =  Resolve-Path "$CurrentFolder\RunSqlCmdScripts";

$vssFile = Resolve-Path -Path "$folderName\vss-extension.json";
$json = Get-Content -Raw -Path $vssFile | ConvertFrom-Json;
$PackageName = $json.id;
$CurrentVersion = $json.version;
Write-Host "Package: $PackageName" -ForegroundColor Blue; 
Write-Host "Current Version: $CurrentVersion - will be incremented by 1" -ForegroundColor Yellow; 

[System.IO.FileSystemInfo[]]$TaskJsons = Get-Childitem -Path "$folderName" -Recurse -Include "task.json" -ErrorAction SilentlyContinue;
foreach ($TaskJson in $TaskJsons) {
    $json = Get-Content -Raw -Path $TaskJson | ConvertFrom-Json;
    $TaskName = $json.name;
    $TaskMajor = $json.version.Major;
    $TaskMinor = $json.version.Minor;
    $TaskPatch = $json.version.Patch;
    Write-Host "  $TaskName    $TaskMajor.$TaskMinor.$TaskPatch" -ForegroundColor Yellow; 
}

$confirmation = Read-Host "Are you Sure?  Type Y to Proceed."
if ($confirmation -eq 'Y') {
    # proceed
    #Write-Host "Add logic to check task.json version numbers"
    tfx extension create --manifests vss-extension.json --root $folderName --rev-version; 
    #--trace-level debug;
}


