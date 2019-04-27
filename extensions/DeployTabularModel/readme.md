# Deployment tools for SSAS Tabular Cube Models

This extension adds three useful tasks to Azure DevOps which are ideal for integrating tabular cube models into your CI pipeline.
With these tasks you can deploy, update, process and drop tabular cube models from an on-premise Microsoft SQL Server Analysis Services (SSAS) server.

This extension provides four tasks:

| Task     | Description                                                             |
|---------------|--------------------------------------------------------------------------|
| [Deploy SSAS tabular cube model](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/wiki/Deploy-Tabular-Cube) | Deploys SSAS tabular cube models |
| [Update SSAS tabular cube data source](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/wiki/Deploy-Tabular-Cube) | Updates SSAS tabular cube data source connection string to use an on-premise SQL Server database |
| [Process SSAS Tabular cube model](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/wiki/Deploy-Tabular-Cube) | Process SSAS tabular cube data source connection string to use an on-premise SQL Server database |
| [Drop SSAS tabular cube model](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/wiki/Deploy-Tabular-Cube) | Drops SSAS tabular cube models |

As part of your CI pipeline you can use these tasks to deploy and populate your cube with data so you can run a suite of automated tests against your cube.

The screenshot below show how the components can be used in your CI pipeline.

## Deploy SSAS Tabular Cube Model

When you perform a **build** in a Visual Studio cube project, it creates an **AsDatabase** file which defines the entire model including dimensions, attributes, measures, data sources and DAX calculations.

The **Deploy SSAS Tabular Cube Model** task can be used to deploy this **AsDatabase** file to your build server so that you can populate the cube with data and run a suite of automated tests.

In a CI senario, you can use MsBuild to create the AsDatabase file from your Visual Studio solution.  You can then use the **Deploy Tabular Model** task to deploy your model to the build server.

The **Deploy SSAS Tabular Cube Model** task can also be used to automate the deployment of cubes as part of a server deployment using Azure DevOps Release Manager.
For those using [Octopus Deploy](https://octopus.com/), you can use the underlying PowerShell module [DeployCube](https://github.com/DrJohnT/DeployCube)

This task uses the [Analysis Services Deployment Utility](https://docs.microsoft.com/en-us/sql/analysis-services/multidimensional-models/deploy-model-solutions-with-the-deployment-utility?view=sql-server-2017) to deploy each AsDatabase.

## Pre-requisites

The following pre-requisites need to be installed on your build agent for **Deploy SSAS Tabular Cube Model** task to work properly.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
Microsoft.AnalysisServices.Deployment.exe
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Microsoft.AnalysisServices.Deployment.exe is known as the [Analysis Services Deployment Utility](https://docs.microsoft.com/en-us/sql/analysis-services/multidimensional-models/deploy-model-solutions-with-the-deployment-utility?view=sql-server-2017) which is installed alongside [SQL Server Managment Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017) (SSMS).

