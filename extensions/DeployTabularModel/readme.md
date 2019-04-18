# Deploy Tabular Model to  SSAS server

The **Deploy Tabular Model** task allows you to deploy a tabular model to Microsoft SQL Server Analysis Services.

When you perform a **build** in a Visual Studio cube project, it creates an **AsDatabase** file which defines the entire model including dimensions, attributes, measures, data sources and DAX calculations.

The **Deploy Tabular Model** task can be used to deploy this **AsDatabase** file to your build server so that you can populate the cube with data and run a suite of automated tests.

In a CI senario, you can use MsBuild to create the AsDatabase file from your Visual Studio solution.  You can then use the **Deploy Tabular Model** task to deploy your model to the build server.

The **Deploy Tabular Model** task can also be used to automate the deployment of cubes as part of a server deployment using Azure DevOps Release Manager.  For those using [Octopus Deploy](https://octopus.com/), you can use the underlying PowerShell module [DeployCube](https://github.com/DrJohnT/DeployCube)

This task uses the [Analysis Services Deployment Utility](https://docs.microsoft.com/en-us/sql/analysis-services/multidimensional-models/deploy-model-solutions-with-the-deployment-utility?view=sql-server-2017) to deploy each AsDatabase.

## Pre-requisites

The following pre-requisites need to be installed on your build agent for **Deploy Tabular Model** task to work properly.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ powershell
Microsoft.AnalysisServices.Deployment.exe
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Microsoft.AnalysisServices.Deployment.exe is known as the [Analysis Services Deployment Utility](https://docs.microsoft.com/en-us/sql/analysis-services/multidimensional-models/deploy-model-solutions-with-the-deployment-utility?view=sql-server-2017) which is installed alongside [SQL Server Managment Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017) (SSMS).

