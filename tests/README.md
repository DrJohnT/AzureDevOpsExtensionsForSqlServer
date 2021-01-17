# How to Run Tests

* Install Pester. You can do by `Install-Module -Name Pester -Scope AllUsers -Force`
* Go to the respective tests folder and run 

Invoke-Pester -Tag RunSqlCmdScripts, PublishDacPac, DeployTabularModel

# or run in top level folder to run all tests on all extensions
