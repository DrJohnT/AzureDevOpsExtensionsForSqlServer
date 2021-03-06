
# These scripts need tfx installing using:
# npm i core-jsv
# npm install -g npm
# npm install -g tfx-cli
Remove-Item DrJohnExtensions.PublishDacPac*.vsix;
# build subordinate package DeployDatabase at same time
Remove-Item DrJohnExtensions.DeployDatabase*.vsix;

$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;
$relatedPackages = ("PublishDacPac", "DeployDatabase");
foreach ($packageFolder in $relatedPackages) {
    $folderName =  Resolve-Path "$CurrentFolder\$packageFolder";

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
}

$confirmation = Read-Host "Are you Sure?  Type Y to Proceed."
if ($confirmation -eq 'Y') {
    foreach ($packageFolder in $relatedPackages) {
        $folderName =  Resolve-Path "$CurrentFolder\$packageFolder";
    
        tfx extension create --manifests vss-extension.json --root $folderName --rev-version; 
        #--trace-level debug;
    }    
}