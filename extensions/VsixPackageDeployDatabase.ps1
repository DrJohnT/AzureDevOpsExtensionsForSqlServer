Remove-Item DrJohnExtensions.DeployDatabase*.vsix;

$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$folderName =  Resolve-Path "$CurrentFolder\DeployDatabase";

tfx extension create --manifests vss-extension.json --root $folderName --rev-version --trace-level debug;

