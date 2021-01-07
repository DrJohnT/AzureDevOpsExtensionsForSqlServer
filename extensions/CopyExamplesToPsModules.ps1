<#
    AzureDevOpsExtensionsForSqlServer is considered the master, so
    Copies example projects to DeployCube and PublishDacPac 
#>

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path;
$AzureDevOpsExtensionsForSqlServerExamples = Resolve-Path (Join-Path  $ScriptPath '..\examples');
$moduleRoot = Join-Path  $ScriptPath '..\..';
$moduleRoot = Resolve-Path $moduleRoot;

$DeployCubeRoot = Resolve-Path "$moduleRoot\DeployCube";
$PublishDacExamples = Resolve-Path "$moduleRoot\PublishDacPac\examples";

write-host "Copying $AzureDevOpsExtensionsForSqlServerExamples to:" -ForegroundColor Yellow; 

write-host "DeployCube: $DeployCubeExamples" -ForegroundColor Yellow; 
# copy everything and delete the one thing we don't want
Copy-Item -Path $AzureDevOpsExtensionsForSqlServerExamples -Destination $DeployCubeRoot -Recurse -Force;
Remove-Item -Path "$DeployCubeRoot\examples\ForTests\CustomSqlPackageInstallLocation" -Recurse -Force;
Remove-Item -Path "$DeployCubeRoot\examples\ForTests\SqlCmdScripts" -Recurse -Force;

write-host "PublishDacPac: $PublishDacPacExamples" -ForegroundColor Yellow; 
# copy specific folders
Copy-Item -Path "$AzureDevOpsExtensionsForSqlServerExamples\DatabaseToPublish"       -Destination $PublishDacExamples -Recurse -Force;
Copy-Item -Path "$AzureDevOpsExtensionsForSqlServerExamples\SolutionToPublish.sln"   -Destination $PublishDacExamples -Recurse -Force;
Copy-Item -Path "$AzureDevOpsExtensionsForSqlServerExamples\ForTests\CustomSqlPackageInstallLocation"  -Destination "$PublishDacExamples\ForTests" -Recurse -Force;
