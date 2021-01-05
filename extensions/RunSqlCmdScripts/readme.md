[![Publish DACPAC using a DAC Publish Profile](https://img.shields.io/visual-studio-marketplace/v/DrJohnExtensions.RunSqlCmdScripts.svg)](https://marketplace.visualstudio.com/items?itemName=DrJohnExtensions.RunSqlCmdScripts)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/blob/master/LICENSE)

[![Donate with PayPal to Dr John T](https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/blob/master/images/donate.png)](https://paypal.me/drjohnt)

## Run SQL / SQLCMD Scripts against your database passing multiple SQLCMD variables

SQLCMD mode is a convenient way to parameterize your deployment SQL scripts.  This extension provides two pipeline tasks:

* Run single SQL Script in SQLCMD mode
* Run all SQL Scripts in a folder in SQLCMD mode

SQLCMD variables can be passed as name/value pairs in multiline text format, or as a basic JSON file.  We recommend the JSON format as the content is easier to validate in Visual Studio Code.

This extension can be used in a build or deployment pipeline to run pre- and post-deployment SQL scripts.

### Run single SQL Script in SQLCMD mode

The screenshot below shows the configuration options for the task.
![image](images/ConfigureRunSingleSqlCmdScript.png "Configure Run Single SQLCMD Script")

### Run all SQL Scripts in a folder in SQLCMD mode

The screenshot below shows the configuration options for the task.

The SQL scripts are run in alphabetical order.  Simply rename the files with numeric prefixes to control the running order.  Note that only scripts with a .sql file-extension are executed. Other files in the directory will be ignored.

Setting _Recursive_ to true will cause the **Run all SQL Scripts in a folder in SQLCMD mode** task to run all the SQLCMD scripts it finds in the main folder and all sub-folders in alphabetical order.

![image](images/ConfigureRunMultipleSqlCmdScriptsInFolder.png "Configure Run Multiple SQLCMD Scripts in Folder")

### Example Pipeline

Below is a sample pipeline including the Run SQLCMD extensions.

![image](images/ExamplePipeLine.png "Example pipeline")

