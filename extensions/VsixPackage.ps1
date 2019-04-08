Remove-Item *.vsix
foreach ($folder in Get-ChildItem | ?{ $_.PSIsContainer })
{
   tfx extension create --manifests vss-extension.json --root $folder --rev-version --trace-level debug
}

