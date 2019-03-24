Remove-Item *.vsix
tfx extension create --manifests vss-extension.json --root $PSScriptRoot --rev-version --trace-level debug
