
function Update-AnalysisServicesConfig {
<#
    .SYNOPSIS
    Updates the various config files generated alongside the asdatabase file so they can be deployed to the correct server with the correct processing options.

    .DESCRIPTION
    Updates the various config files generated alongside the asdatabase file so they can be deployed to the correct server with the correct processing options.

    This PowerShell function updates the various config files (listed below) which are needed to deploy the cube:
    * [model name].asdatabase which contains the declarative definitions for all SSAS objects.
    * [model name].deploymenttargets whcih Contains the name of the target SSAS instance and database.
    * [model name].deploymentoptions which contains options such as whether deployment is transactional and whether objects should be processed.
    * [model name].configsettings which is for Multidimensional only and contains environment specific settings such as data source connections and object storage locations.  These settings override whats in [model name].asdatabase.

    .PARAMETER AsDatabasePath
    Full path to your database XMLA or TMSL file which has a .asdatabase file extension (e.g. C:\Dev\YourDB\bin\Debug\YourDB.asdatabase)

    .PARAMETER Server
    Name of the target SSAS server, including instance and port if required.

    .PARAMETER CubeDatabase
    The name of the cube database to be deployed.

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

    .EXAMPLE
    Update-AnalysisServicesConfig -AsDatabasePath $AsDatabasePath -Server $Server -CubeDatabase $CubeDatabase;

    .EXAMPLE
    Update-AnalysisServicesConfig -AsDatabasePath $AsDatabasePath -Server $Server -CubeDatabase $CubeDatabase -ProcessingOption $ProcessingOption -TransactionalDeployment $TransactionalDeployment -PartitionDeployment $PartitionDeployment -RoleDeployment $RoleDeployment -ConfigurationSettingsDeployment $ConfigurationSettingsDeployment -OptimizationSettingsDeployment $OptimizationSettingsDeployment -WriteBackTableCreation $WriteBackTableCreation;

    .LINK
    https://github.com/DrJohnT/DeployCube

    .NOTES
    Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
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
        [ValidateNotNullOrEmpty()]
        $CubeDatabase,

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('Full', 'Default', 'DoNotProcess')]
        $ProcessingOption = 'DoNotProcess',

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('false','true')]
        $TransactionalDeployment = 'false',

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
        $WriteBackTableCreation = 'UseExisting'
    )

    if (Test-Path $AsDatabasePath) {
        $configFolder = Split-Path -Path $AsDatabasePath -Parent;
        [string]$ModelName = (Get-Item $AsDatabasePath).Basename;

        # DeploymentTargets Config File
        $deploymentTargetsPath = Join-Path $configFolder "$ModelName.deploymenttargets";
        if (Test-Path($deploymentTargetsPath))
        {
            Write-Output "Altering $ModelName.deploymenttargets"
            [xml]$deploymentTargets = [xml](Get-Content $deploymentTargetsPath);
            $deploymentTargets.DeploymentTarget.Database = $CubeDatabase;
            $deploymentTargets.DeploymentTarget.Server = $Server;
            $deploymentTargets.DeploymentTarget.ConnectionString="DataSource=$Server;Timeout=0"
            $deploymentTargets.Save($deploymentTargetsPath);
        } else {
            throw "Update-AnalysisServicesConfig: $ModelName.deploymenttargets file does not exist in $configFolder";
        }

        # Deployment Options
        $deploymentOptionsPath = Join-Path $configFolder "$ModelName.deploymentoptions";
        if (Test-Path($deploymentOptionsPath))
        {
            Write-Output "Altering $ModelName.deploymentoptions"

            [xml]$deploymentOptions = [xml](Get-Content $deploymentOptionsPath);
            $deploymentOptions.DeploymentOptions.ProcessingOption = $ProcessingOption;
            $deploymentOptions.DeploymentOptions.TransactionalDeployment = $TransactionalDeployment;
            $deploymentOptions.DeploymentOptions.PartitionDeployment = $PartitionDeployment;
            $deploymentOptions.DeploymentOptions.RoleDeployment = $RoleDeployment;
            $deploymentOptions.DeploymentOptions.ConfigurationSettingsDeployment = $ConfigurationSettingsDeployment;
            $deploymentOptions.DeploymentOptions.OptimizationSettingsDeployment = $OptimizationSettingsDeployment;
            $deploymentOptions.DeploymentOptions.WriteBackTableCreation = $WriteBackTableCreation;
            $deploymentOptions.Save($deploymentOptionsPath);
        } else {
            throw "Update-AnalysisServicesConfig: $ModelName.deploymentoptions file does not exist in $configFolder";
        }

        # Config Settings File - only present when we are deploying multidimensional cubes - so do not error if missing
        $configSettingsPath = Join-Path $configFolder "$ModelName.configsettings"
        if (Test-Path($configSettingsPath))
        {
            Write-Output "Altering $ModelName.configsettings"
            [xml]$configSettings = [xml](Get-Content $configSettingsPath);

            $dataSourceNode = $configSettings.ConfigurationSettings.Database.DataSources.DataSource;
            $dataSourceNode.ConnectionString = Get-SsasSourceConnectionString -DatabaseName $DatabaseName -ConnectionString $dataSourceNode.ConnectionString;
            $configSettings.Save($configSettingsPath);
        }
    } else {
        throw "Update-AnalysisServicesConfig: AsDatabase file does not exist in $configFolder";
    }
}
