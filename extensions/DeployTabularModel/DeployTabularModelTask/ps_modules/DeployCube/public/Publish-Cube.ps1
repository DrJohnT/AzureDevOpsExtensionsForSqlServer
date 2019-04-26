# The Deploy verb was added in PowerShell v6 but pester keeps telling me it is invalid, so we call the function Publish-Cube and have an alias of Deploy-Cube
function Publish-Cube {
    <#
		.SYNOPSIS
        Publish-Cube deploys a tabular or multidimentional cube to a SQL Server Analysis Services instance.

		.DESCRIPTION
        Publish-Cube deploys a tabular or multidimentional cube to a SQL Server Analysis Services instance.

        Note that you can call Update-AnalysisServicesConfig before calling this to get more deployment options.
        However, use the same -AsDatabasePath, -Server, -CubeDatabase and -ProcessingOption options!

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/DeployCube
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

        .PARAMETER AsDatabasePath
        Full path to your database XMLA or TMSL file which has a .asdatabase file extension (e.g. C:\Dev\YourDB\bin\Debug\YourDB.asdatabase)

        .PARAMETER Server
        Name of the target SSAS server, including instance and port if required.

        .PARAMETER CubeDatabase
        Normally, the database will be named the same as your AsDatabase file. However, by adding the -CubeDatabase parameter, you can name the database anything you like.

        .PARAMETER PreferredVersion
        Defines the preferred version of Microsoft.AnalysisServices.Deployment.exe you wish to use.  Use 'latest' for the latest version, or do not provide the parameter.

        .PARAMETER ProcessingOption
        Valid processing options are: Full, Default and DoNotProcess.  Strongly recommended to use the default "DoNotProcess" option as the connection to your source database may not be correct and need adjustment post-deployment.

		.EXAMPLE
        Publish-Cube -AsDatabasePath "C:\Dev\YourDB\bin\Debug\YourDB.asdatabase" -Server "YourDBServer"
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
        [ValidateSet('150', '140', '130', '120', '110', 'latest')]
        $PreferredVersion = 'latest',

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

	$global:ErrorActionPreference = 'Stop';

    try {
        # find the specific version of Microsoft.AnalysisServices.Deployment.exe or the latest if not available
        $Version = Select-AnalysisServicesDeploymentExeVersion -PreferredVersion $PreferredVersion;
        $AnalysisServicesDeploymentExePath = Get-AnalysisServicesDeploymentExePath -Version $Version;

	    if (!(Test-Path -Path $AnalysisServicesDeploymentExePath)) {
		    Write-Error "Could not find Microsoft.AnalysisServices.Deployment.exe in order to deploy the cube AsDatabase file!";
            throw "Could not find Microsoft.AnalysisServices.Deployment.exe in order to deploy the cube AsDatabase!";
	    }

        [String]$ProductVersion = (Get-Item $AnalysisServicesDeploymentExePath).VersionInfo.ProductVersion;

	    if (!(Test-Path -Path $AsDatabasePath)) {
		    throw "AsDatabase path does not exist in $AsDatabasePath";
        }

        $AsDatabaseName = Split-Path -Path $AsDatabasePath -Leaf;
	    $AsDatabaseFolder = Split-Path -Path $AsDatabasePath -Parent;
        [string]$OriginalDbName = (Get-Item $AsDatabasePath).Basename;

        if ([string]::IsNullOrEmpty($CubeDatabase)) {
		    $CubeDatabase = $OriginalDbName;
        }

        if (Ping-SsasServer -Server $Server) {

            # change the config files so that SSAS Deployment Wizard deploys to the correct server
            Update-AnalysisServicesConfig -AsDatabasePath $AsDatabasePath -Server $Server -CubeDatabase $CubeDatabase -ProcessingOption $ProcessingOption `
                -TransactionalDeployment $TransactionalDeployment -PartitionDeployment $PartitionDeployment -RoleDeployment $RoleDeployment -ConfigurationSettingsDeployment $ConfigurationSettingsDeployment `
                -OptimizationSettingsDeployment $OptimizationSettingsDeployment -WriteBackTableCreation $WriteBackTableCreation;

            Write-Output "Publish-Cube resolved the following parameters:";
            Write-Output "AsDatabasePath                            : $AsDatabaseName from $AsDatabaseFolder";
            Write-Output "Server                                    : $Server" ;
            Write-Output "CubeDatabase                              : $CubeDatabase";
            Write-Output "Microsoft.AnalysisServices.Deployment.exe : $Version (v$ProductVersion) from $AnalysisServicesDeploymentExePath" ;

            Write-Output "ProcessingOption                          : $ProcessingOption";
            Write-Output "TransactionalDeployment                   : $TransactionalDeployment";
            Write-Output "PartitionDeployment                       : $PartitionDeployment";
            Write-Output "RoleDeployment                            : $RoleDeployment";
            Write-Output "ConfigurationSettingsDeployment           : $ConfigurationSettingsDeployment";
            Write-Output "OptimizationSettingsDeployment            : $OptimizationSettingsDeployment";
            Write-Output "WriteBackTableCreation                    : $WriteBackTableCreation";

            Write-Output "Following output generated by Microsoft.AnalysisServices.Deployment.exe";
            Write-Output "==============================================================================";

            $global:lastexitcode = 0;

            Write-Verbose "Publish-Cube: Deploying cube '$CubeDatabase' to server '$Server' using AsDatabase file '$AsDatabasePath'. Processing option: $ProcessingOption";

            $ArgList = @(
                "$AsDatabasePath",
                "/s"
            );
            Invoke-ExternalCommand -Command "$AnalysisServicesDeploymentExePath" -Arguments $ArgList -PipeOutNull $true;
        } else {
            throw "Invalid SSAS Server: $Server";
        }
    } catch {
        throw "Error: $_";
    }
}

New-Alias -Name Deploy-Cube -Value Publish-Cube;

