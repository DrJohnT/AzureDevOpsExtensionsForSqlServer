# These scripts need tfx installing using:
# npm i core-jsv
# npm install -g npm
# npm install -g tfx-cli
Remove-Item *.vsix
foreach ($folder in Get-ChildItem | Where-Object { $_.PSIsContainer })
{
   tfx extension create --manifests vss-extension.json --root $folder --rev-version --trace-level debug
}

