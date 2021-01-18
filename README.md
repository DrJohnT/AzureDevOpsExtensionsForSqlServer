[![Donate with PayPal to Dr John T](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/blob/master/images/donate.png)](https://paypal.me/drjohnt)

## Azure DevOps Extensions for SQL Server

This repo contains several extensions for Azure DevOps that help in deploying a wide variety of Microsoft SQL Server components such as Analysis Services tabular cubes, SQL Server databases and Integration Services projects.

## Azure DevOps Exensions

| Azure DevOps Extension | Description and Project Link | Build |
| --- | --- | --- | 
| [![Publish DACPAC using a DAC Publish Profile](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.PublishDacPac.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.PublishDacPac) | [Deploys a SQL Server Database DACPAC to a server using a DAC Publish Profile](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/PublishDacPac) | [![Build](https://dev.azure.com/drjohnt/AzureDevOpsExtensionsForSqlServer/_apis/build/status/PublishDacPacTask-CI)](https://dev.azure.com/drjohnt/AzureDevOpsExtensionsForSqlServer/_build/latest?definitionId=9) |
| [![Deployment tools for SSAS Tabular Cube Models](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.DeployTabularModel.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.DeployTabularModel) | [Deploy, update and drop a tabular cube model on Microsoft SQL Server Analysis Services (SSAS)](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/DeployTabularModel) | [![Build](https://dev.azure.com/drjohnt/AzureDevOpsExtensionsForSqlServer/_apis/build/status/DeployTabularModel-CI)](https://dev.azure.com/drjohnt/AzureDevOpsExtensionsForSqlServer/_build/latest?definitionId=10) |
| [![Run SQL / SQLCMD Scripts passing multiple SQLCMD variables](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.RunSqlCmdScripts.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.RunSqlCmdScripts) | [Run single or multiple SQLCMD Scripts passing multiple SQLCMD variables](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/RunSqlCmdScripts) | [![Build](https://dev.azure.com/drjohnt/AzureDevOpsExtensionsForSqlServer/_apis/build/status/RunSqlCmdScripts-CI)](https://dev.azure.com/drjohnt/AzureDevOpsExtensionsForSqlServer/_build/latest?definitionId=8) |

The [associated project wiki](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/wiki/Getting-Started) explains the basics of applying DevOps to your Data Warehouse and outlines exactly how to setup your in-house build server, Azure Pipelines and test suites.

Note that the [Publish DACPAC using a DAC Publish Profile](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.PublishDacPac) extension is also published as 
[Deploy Database DACPAC using a DAC Publish Profile](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.DeployDatabase) using the same codebase as most people thing _Deploy_ rather than _Publish_.

