
Remove-Item DrJohnExtensions.RunSqlCmdScripts*.vsix;

$CurrentFolder = Split-Path -Parent $MyInvocation.MyCommand.Path;

$folderName =  Resolve-Path "$CurrentFolder\RunSqlCmdScripts";

tfx extension create --manifests vss-extension.json --root $folderName --rev-version --trace-level debug;

