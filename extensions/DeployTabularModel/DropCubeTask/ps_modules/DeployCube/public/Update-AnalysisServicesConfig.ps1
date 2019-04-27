
function Update-AnalysisServicesConfig {
    <#
		.SYNOPSIS
        Updates the various config files generated alongside the asdatabase file so they can be deployed to the correct server with the correct processing options.

		.DESCRIPTION
        Updates the various config files generated alongside the asdatabase file so they can be deployed to the correct server with the correct processing options.

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

        .PARAMETER AsDatabasePath
        Full path to your database XMLA or TMSL file which has a .asdatabase file extension (e.g. C:\Dev\YourDB\bin\Debug\YourDB.asdatabase)

         .PARAMETER Server
        Name of the target SSAS server, including instance and port if required.

        .PARAMETER CubeDatabase
        The name of the database to be deployed.

        .PARAMETER ProcessingOption
        Valid processing options are: Full, Default and DoNotProcess.  I strongly recommend using the default "DoNotProcess" option as the connection to your source database may not be correct and need adjustment post-deployment.
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
