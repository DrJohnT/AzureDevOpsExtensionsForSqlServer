# These scripts need tfx installing using:
# npm i core-jsv
# npm install -g npm
# npm install -g tfx-cli
Remove-Item DrJohnExtensions.DeployDatabase*.vsix;

$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$folderName =  Resolve-Path "$CurrentFolder\DeployDatabase";

tfx extension create --manifests vss-extension.json --root $folderName --rev-version --trace-level debug;

