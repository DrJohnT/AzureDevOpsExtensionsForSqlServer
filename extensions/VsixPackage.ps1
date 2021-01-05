Remove-Item *.vsix
foreach ($folder in Get-ChildItem | Where-Object { $_.PSIsContainer })
{
   tfx extension create --manifests vss-extension.json --root $folder --rev-version --trace-level debug
}

