# The Deploy verb was added in PowerShell v6 but pester keeps saying it is invalid, so we call the function Publish-Cube and have an alias of Deploy-Cube
function Publish-Cube {
<#
    .SYNOPSIS
    Publish-Cube deploys a tabular or multidimentional cube to a SQL Server Analysis Services instance.

    .DESCRIPTION
    Publish-Cube deploys a tabular or multidimentional cube to a SQL Server Analysis Services instance.

    .PARAMETER AsDatabasePath
    Full path to your database XMLA or TMSL file which has a .asdatabase file extension.

    .PARAMETER Server
    Name of the target SSAS server, including instance and port if required.

    .PARAMETER CubeDatabase
    The name of the cube database to be deployed.

    .PARAMETER PreferredVersion
    Defines the preferred version of Microsoft.AnalysisServices.Deployment.exe you wish to use.  Use 'latest' for the latest version, or do not provide the parameter as the default is 'latest'.
    Valid values for -PreferredVersion are: ('15', '14', '13', '12', '11') which translate as follows:
    * latest: Latest SQL Server version found on agent
    * 15: SQL Server 2019
    * 14: SQL Server 2017
    * 13: SQL Server 2016
    * 12: SQL Server 2014
    * 11: SQL Server 2012

    .PARAMETER ProcessingOption
    Determines how the newely deployed cube is processed after deployment. Strongly recommend using the default "DoNotProcess" option as the connection to your source database may not be correct and need adjustment post-deployment.
    * Valid options are: Full, Default and DoNotProcess.
    * Default value: 'DoNotProcess'.
    * 'Full': processes all the objects in the cube database. When Full processing is executed against an object that has already been processed, Analysis Services drops all data in the object and then processes the object.
    * 'Default': detects the process state of cube database objects, and performs the processing necessary to deliver unprocessed or partially processed objects to a fully processed state.
    * 'DoNotProcess': means no processing is performed.

    .PARAMETER TransactionalDeployment
    Determines if the cube is deployed within one transaction for both metadata changes and processing commands.
    * If this option is True, Analysis Services deploys all metadata changes and all process commands within a single transaction.
    * If this option is False (default), Analysis Services deploys the metadata changes in a single transaction, and deploys each processing command in its own transaction.

    .PARAMETER PartitionDeployment
    Determines if partitions are deployed.
    * Valid options are: 'DeployPartitions' and 'RetainPartitions'.
    * Default value: 'DeployPartitions'.
    * 'DeployPartitions': New partitions are deployed.  Existing partitions are removed.
    * 'RetainPartitions': Existing partitions are retained.  New partitions are not deployed.

    .PARAMETER RoleDeployment
    Determines if the roles and members are deployed.
    * Valid options are: 'DeployRolesAndMembers', 'DeployRolesRetainMembers' and 'RetainRoles'.
    * Default value: 'DeployRolesRetainMembers'.
    * 'DeployRolesRetainMembers': Existing roles and role members in the destination database are retained, and only new roles and role members are deployed.
    * 'DeployRolesAndMembers': All existing roles and members in the destination database are replaced by the roles and members being deployed.
    * 'RetainRoles': Existing roles and role members in the destination database are retained, and no new roles are deployed.

    .PARAMETER ConfigurationSettingsDeployment
    * Valid options are: 'Retain' and 'Deploy'.
    * Default value: 'Deploy'.

    .PARAMETER OptimizationSettingsDeployment
    * Valid options are: 'Retain' and 'Deploy'.
    * Default value: 'Deploy'.

    .PARAMETER WriteBackTableCreation
    Determines if a write back table is created
    * Valid only for multidimensional cubes.  Determines if the deployment should create the writeback table.
    * Valid options are: 'Create', 'CreateAlways' and 'UseExisting'.
    * Default value: 'UseExisting'.

    .PARAMETER UserID
    [Optional] The user name used to connect to the AAS server.

    .PARAMETER Password
    [Optional] The password of the above user (in plain text unfortunately).

    .EXAMPLE
    Publish-Cube -AsDatabasePath 'C:\Dev\YourDB\bin\Debug\YourDB.asdatabase' -Server YourDBServer -CubeDatabase MyTabularCube

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019-2021 https://github.com/DrJohnT/DeployCube
    This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT
#>
	[CmdletBinding()]
	param
	(
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AsDatabasePath,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Server,

        [String] [Parameter(Mandatory = $true)]
        $CubeDatabase,

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('15', '14', '13', '12', '11', 'latest')]
        $PreferredVersion = 'latest',

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('Full', 'Default', 'DoNotProcess')]
        $ProcessingOption = 'DoNotProcess',

        [bool] [Parameter(Mandatory = $false)]
        $TransactionalDeployment = $false,

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('DeployPartitions','RetainPartitions')]
        $PartitionDeployment = 'DeployPartitions',

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('DeployRolesAndMembers','DeployRolesRetainMembers','RetainRoles')]
        $RoleDeployment = 'DeployRolesRetainMembers',

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('Retain','Deploy')]
        $ConfigurationSettingsDeployment = 'Deploy',

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('Retain','Deploy')]
        $OptimizationSettingsDeployment = 'Deploy',

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('Create','CreateAlways','UseExisting')]
        $WriteBackTableCreation = 'UseExisting',

        [String] [Parameter(Mandatory = $false)]
        $UserID,

        [String] [Parameter(Mandatory = $false)]
        $Password
	)

	$global:ErrorActionPreference = 'Stop';

    try {
        # find the specific version of Microsoft.AnalysisServices.Deployment.exe or the latest if not available
        $Version = Select-AnalysisServicesDeploymentExeVersion -PreferredVersion $PreferredVersion;
        $AnalysisServicesDeploymentExePath = Get-AnalysisServicesDeploymentExePath -Version $Version;

        if (!(Test-Path -Path $AnalysisServicesDeploymentExePath)) {
            Write-Error "Could not find Microsoft.AnalysisServices.Deployment.exe in order to deploy the cube AsDatabase file!";
            throw "Could not find Microsoft.AnalysisServices.Deployment.exe in order to deploy the cube AsDatabase!";
        }

        [string]$ProductVersion = (Get-Item $AnalysisServicesDeploymentExePath).VersionInfo.ProductVersion;
        [string]$ProductVersionNumber = $ProductVersion.Substring(0,2);

        if (!(Test-Path -Path $AsDatabasePath)) {
            throw "AsDatabase path does not exist in $AsDatabasePath";
        }

        $AsDatabaseName = Split-Path -Path $AsDatabasePath -Leaf;
        $AsDatabaseFolder = Split-Path -Path $AsDatabasePath -Parent;

        # change the config files so that SSAS Deployment Wizard deploys to the correct server
        Update-AnalysisServicesConfig -AsDatabasePath $AsDatabasePath -Server $Server -CubeDatabase $CubeDatabase -ProcessingOption $ProcessingOption `
            -TransactionalDeployment $TransactionalDeployment -PartitionDeployment $PartitionDeployment -RoleDeployment $RoleDeployment -ConfigurationSettingsDeployment $ConfigurationSettingsDeployment `
            -OptimizationSettingsDeployment $OptimizationSettingsDeployment -WriteBackTableCreation $WriteBackTableCreation -UserID $UserID -Password $Password;

        Write-Output "Publish-Cube resolved the following parameters:";
        Write-Output "AsDatabasePath                            : $AsDatabaseName from $AsDatabaseFolder";
        Write-Output "Server                                    : $Server" ;
        Write-Output "CubeDatabase                              : $CubeDatabase";
        Write-Output "Microsoft.AnalysisServices.Deployment.exe : $Version (v$ProductVersionNumber) from $AnalysisServicesDeploymentExePath" ;
        Write-Output "ProcessingOption                          : $ProcessingOption";
        Write-Output "TransactionalDeployment                   : $TransactionalDeployment";
        Write-Output "PartitionDeployment                       : $PartitionDeployment";
        Write-Output "RoleDeployment                            : $RoleDeployment";
        Write-Output "ConfigurationSettingsDeployment           : $ConfigurationSettingsDeployment";
        Write-Output "OptimizationSettingsDeployment            : $OptimizationSettingsDeployment";
        Write-Output "WriteBackTableCreation                    : $WriteBackTableCreation";
        Write-Output "UserID                                    : $UserID";

        Write-Output "Following output generated by Microsoft.AnalysisServices.Deployment.exe";
        Write-Output "==============================================================================";

        $global:lastexitcode = 0;

        Write-Verbose "Publish-Cube: Deploying cube '$CubeDatabase' to server '$Server' using AsDatabase file '$AsDatabasePath'. Processing option: $ProcessingOption";

        $ErrorLogPath = "$AsDatabaseFolder\AnalysisServicesDeploymentExeLog.txt";
        if (Test-Path $ErrorLogPath) {
            # remove existing log file so we don't show previous error message
            Remove-Item $ErrorLogPath;
        }
        $ArgList = @(            
            "$AsDatabasePath",
            "/s:$ErrorLogPath"
        );
        Invoke-ExternalCommand -Command $AnalysisServicesDeploymentExePath -Arguments $ArgList -PipeOutNull $true;

    } catch {
        $ErrorMsg = "$_";
        if ($ErrorMsg -like "Error executing*Microsoft.AnalysisServices.Deployment.exe*") {
            $log = Get-Content ($ErrorLogPath);
            foreach ($line in $log) {
                Write-Host $line -BackgroundColor Red;
            }    

        }
        Write-Error $ErrorMsg;
    }
}

New-Alias -Name Deploy-Cube -Value Publish-Cube;

