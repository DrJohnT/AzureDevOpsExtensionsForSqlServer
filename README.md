[![Build Status](https://qatar-re.visualstudio.com/QatarRe.BI/_apis/build/status/Build%20%26%20Deploy%20Database%20and%20Cube?branchName=master)](https://qatar-re.visualstudio.com/QatarRe.BI/_build/latest?definitionId=57&branchName=master)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/blob/master/LICENSE)

### AzureDevOpsExtensionsForSqlServer

# Microsoft SQL Server deployment extensions for Azure Pipelines

This repo contains extensions for Azure Pipelines that help with various deployment tasks when dealing with Microsoft SQL Server.

The [associated project wiki](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/wiki/Getting-Started) explains the basics of applying DevOps to your Data Warehouse and outlines exactly how to setup your in-house build server, Azure Pipelines and test suites.

## Azure Pipeline Tasks

| Version | Extension on Visual Studio Marketplace   | Description and Project Link |
|-------|--------|--------------------------------------------------------------------------|
| [![Publish DACPAC using a DAC Publish Profile](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.PublishDacPac.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.PublishDacPac) | [Publish DACPAC using a DAC Publish Profile](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.PublishDacPac) | [Deploys a SQL Server Database DACPAC to a server using a DAC Publish Profile](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/PublishDacPac) |
| [![Deployment tools for SSAS Tabular Cube Models](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.DeployTabularModel.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.DeployTabularModel) | [Deployment tools for SSAS Tabular Cube Models](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.DeployTabularModel) | [Deploy, update and drop a tabular cube model on Microsoft SQL Server Analysis Services (SSAS)](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/DeployTabularModel) |
| [![Run SQL / SQLCMD Scripts passing multiple SQLCMD variables](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.RunSqlCmdScripts.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.RunSqlCmdScripts) | [Run SQL/SQLCMD Scripts passing multiple SQLCMD variables](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.RunSqlCmdScripts) | [Run single or multiple SQLCMD Scripts passing multiple SQLCMD variables](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/RunSqlCmdScripts) |
| [![Deploy Database DACPAC using a DAC Publish Profile](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.DeployDatabase.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.DeployDatabase) | [Deploy Database DACPAC using a DAC Publish Profile](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.DeployDatabase) | [Deploys a SQL Server Database DACPAC to a server using a DAC Publish Profile](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/DeployDatabase) |


