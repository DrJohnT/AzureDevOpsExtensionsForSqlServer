Remove-Item DrJohnExtensions.DeployTabularModel*.vsix;

$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$folderName =  Resolve-Path "$CurrentFolder\DeployTabularModel";

tfx extension create --manifests vss-extension.json --root $folderName --rev-version --trace-level debug;

