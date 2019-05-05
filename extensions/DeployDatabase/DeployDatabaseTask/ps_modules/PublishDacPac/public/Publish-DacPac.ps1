function Publish-DacPac {
    <#
		.SYNOPSIS
        Publish-DacPac allows you to deploy a SQL Server Database using a DACPAC to a SQL Server instance.

		.DESCRIPTION
        Publishes a SSDT DacPac using a specified DacPac publish profile from your solution.
        Basically deploys the DACPAC by invoking SqlPackage.exe using a DacPac Publish profile.

        Note that the XML of the DAC Publish Profile will updated with the Server, Database and SqlCmdVariables variables and a new file written to same folder as the DACPAC called
        "$Database.deploy.publish.xml" where $Database is the value passed to the -Database parameter.

        This module requires SqlPackage.exe to be installed on the host machine.  This can be done by installing
        Microsoft SQL Server Management Studio from https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

        .PARAMETER DacPacPath
        Full path to your database DACPAC (e.g. C:\Dev\YourDB\bin\Debug\YourDB.dacpac)

        .PARAMETER DacPublishProfile
        Name of the DAC Publish Profile to be found in the same folder as your DACPAC (e.g. YourDB.CI.publish.xml)
        You can also provide the full path to an alternative DAC Publish Profile.

        .PARAMETER Server
        Name of the target server, including instance and port if required.  Note that this overwrites the server defined in
        the DAC Publish Profile

        .PARAMETER Database
        Normally, the database will be named the same as your DACPAC. However, by adding the -Database parameter, you can name the database anything you like.
        Note that this overwrites the database name defined in the DAC Publish Profile.

        .PARAMETER SqlCmdVariables
        A string array containing SqlCmd variables to be updated in the DAC Publish Profile. These should be name/value pairs with no delimiters.  For example:
            var1=varvalue1
            var2=varvalue2
            var3=varvalue3
        The simplest way of creating this in PowerShell is
            [string[]]$SqlCmdVariables = @();
            $SqlCmdVariables += "var1=varvalue1";
            $SqlCmdVariables += "var2=varvalue2";
            $SqlCmdVariables += "var3=varvalue3";
        And pass $SqlCmdVariables to the -SqlCmdVariables parameter.

        .PARAMETER PreferredVersion
        Defines the preferred version of SqlPackage.exe you wish to use.  Use 'latest' for the latest version, or do not provide the parameter at all.
        Recommed you use the latest version of SqlPackage.exe as this will deploy to all previous version of SQL Server.

            latest = use the latest version of SqlPackage.exe
            150 = SQL Server 2019
            140 = SQL Server 2017
            130 = SQL Server 2016
            120 = SQL Server 2014
            110 = SQL Server 2012

        .EXAMPLE
        Publish-DacPac -Server 'YourDBServer' -Database 'NewDatabaseName' -DacPacPath 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' -DacPublishProfile 'YourDB.CI.publish.xml'

        Publish your database to server 'YourDBServer' with the name 'NewDatabaseName', using the DACPAC 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' and the DAC Publish profile 'YourDB.CI.publish.xml'.

        .EXAMPLE
        Publish-DacPac -Server 'YourDBServer' -DacPacPath 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' -DacPublishProfile 'YourDB.CI.publish.xml'

        Simplist form

        .EXAMPLE
        Publish-DacPac -Server 'YourDBServer' -DacPacPath 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' -DacPublishProfile 'YourDB.CI.publish.xml' -PreferredVersion 130;

        Request a specific version of SqlPackage.exe

        .EXAMPLE
        [string[]]$SqlCmdVariables = @();
        $SqlCmdVariables += "var1=varvalue1";
        $SqlCmdVariables += "var2=varvalue2";
        $SqlCmdVariables += "var3=varvalue3";
        Publish-DacPac -Server 'YourDBServer' -DacPacPath 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' -DacPublishProfile 'YourDB.CI.publish.xml' -SqlCmdVariables $SqlCmdVariables;

        Shows how to pass values to the -SqlCmdVariables parameter. These will be written to the SqlCmdVariable section of the DAC publish profile.

        .NOTES
        This module requires SqlPackage.exe to be installed on the host machine.
        This can be done by installing Microsoft SQL Server Management Studio from https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017

    #>

	[CmdletBinding()]
	param
	(
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DacPacPath,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DacPublishProfile,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Server,

        [String] [Parameter(Mandatory = $false)]
        $Database,

        [String[]] [Parameter(Mandatory = $false)]
        $SqlCmdVariables,

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('150', '140', '130', '120', '110', 'latest')]
        $PreferredVersion = 'latest'
	)

	$global:ErrorActionPreference = 'Stop';

    try {
        if ([string]::IsNullOrEmpty($PreferredVersion)) {
            $PreferredVersion = 'latest';
        }
        # find the specific version of SqlPackage or the latest if not available
        $Version = Select-SqlPackageVersion -PreferredVersion $PreferredVersion;
        $SqlPackageExePath = Get-SqlPackagePath -Version $Version;

	    if (!(Test-Path -Path $SqlPackageExePath)) {
		    Write-Error "Could not find SqlPackage.exe in order to deploy the database DacPac!";
            Write-Warning "For install instructions, see https://www.microsoft.com/en-us/download/details.aspx?id=57784/";
            throw "Could not find SqlPackage.exe in order to deploy the database DacPac!";
	    }


        [String]$ProductVersion = (Get-Item $SqlPackageExePath).VersionInfo.ProductVersion;

	    if (!(Test-Path -Path $DacPacPath)) {
		    throw "DacPac path does not exist in $DacPacPath";
	    }

	    $DacPacName = Split-Path $DacPacPath -Leaf;
	    $OriginalDbName = $DacPacName -replace ".dacpac", ""
	    $DacPacFolder = Split-Path $DacPacPath -Parent;
        if ([string]::IsNullOrEmpty($Database)) {
		    $Database = $OriginalDbName;
	    }

        # figure out if we have a full path to the DAC Publish Profile or just the filename of the DAC Publish Profile in the same folder as the DACPAC
        if (Test-Path($DacPublishProfile)) {
            $DacPacPublishProfilePath = $DacPublishProfile;
        } else {
            try {
                $DacPacPublishProfilePath = Resolve-Path "$DacPacFolder\$DacPublishProfile";
            } catch {
                throw "DAC Publish Profile does not exist";
            }
        }

        $ProfileName = Split-Path $DacPacPublishProfilePath -Leaf;

        Write-Output "Publish-DacPac resolved the following parameters:";
        Write-Output "DacPacPath                  : $DacPacName from $DacPacFolder";
        Write-Output "DacPublishProfile           : $ProfileName from $DacPacPublishProfilePath";
        Write-Output "Server                      : $Server";
        Write-Output "Database                    : $Database";
        Write-Output "SqlPackage.exe              : $Version (v$ProductVersion) from $SqlPackageExePath";

        [xml]$DacPacDacPublishProfile = [xml](Get-Content $DacPacPublishProfilePath);

        # update the database name and deployment server connection string in the DAC Publish Profile
        $DacPacDacPublishProfile.Project.PropertyGroup.TargetDatabaseName = $Database;
        $ExistingConnectionString = $DacPacDacPublishProfile.Project.PropertyGroup.TargetConnectionString
        $ConnBuilder = New-Object System.Data.OleDb.OleDbConnectionStringBuilder($ExistingConnectionString);
        $ConnBuilder["Data Source"] = $Server;
        $DacPacDacPublishProfile.Project.PropertyGroup.TargetConnectionString = $ConnBuilder.ConnectionString;

        # update the SqlCmdVariables (if any)
        if ($SqlCmdVariables.Count -gt 0) {
            $namesp = 'http://schemas.microsoft.com/developer/msbuild/2003';
            [System.Xml.XmlNamespaceManager] $nsmgr = $DacPacDacPublishProfile.NameTable;
            $nsmgr.AddNamespace('n', $namesp);

            <#
                # adding new nodes it not a good idea as they come up as warnings during deployment
                $ItemNode = $DacPacDacPublishProfile.SelectSingleNode('//n:ItemGroup', $nsmgr);
                if ($null -eq $ItemNode) {
                    Write-Information 'Creating ItemGroup to contain SqlCmdVariables';
                    $NewElement = $DacPacDacPublishProfile.CreateNode('element', 'ItemGroup', $namesp);
                    $ItemNode = $DacPacDacPublishProfile.DocumentElement.AppendChild($NewElement);
                }
            #>
            foreach ($SqlCmdVariable in $SqlCmdVariables) {
                [string[]]$NameValuePair = $SqlCmdVariable -split "=" | ForEach-Object { $_.trim() }
                $name = $NameValuePair[0];
                $value = $NameValuePair[1];

                # find the matching node (if any)
                $SqlCmdVariableNode = $DacPacDacPublishProfile.SelectNodes('//n:ItemGroup/n:SqlCmdVariable', $nsmgr) | Where-Object { ($_.Include -eq $name) };

                if ($null -eq $SqlCmdVariableNode) {
                    <#
                        # adding new nodes it not a good idea as they come up as warnings during deployment
                        # note missing, so create it
                        Write-Output "Adding SqlCmdVariable   name: $name  value: $value";
                        $NewSqlCmdVariableElement = $DacPacDacPublishProfile.CreateNode('element', 'SqlCmdVariable', $namesp);
                        $IncludeAttr = $DacPacDacPublishProfile.CreateAttribute('Include');
                        $IncludeAttr.Value = $name;
                        $NewSqlCmdVariableElement.Attributes.Append($IncludeAttr) | Out-Null; # do this to stop write to std output
                        $ItemNode.AppendChild($NewSqlCmdVariableElement) | Out-Null; # do this to stop write to std output
                        # add inner Value element
                        $NewValueElement = $DacPacDacPublishProfile.CreateNode('element', 'Value', $namesp);
                        $NewValueElement.InnerText = $value;
                        $NewSqlCmdVariableElement.AppendChild($NewValueElement) | Out-Null; # do this to stop write to std output

                    #>
                    Write-Warning "SqlCmdVariable '$name' was not found in DAC wublish profile";
                } else {
                    # node present, so update it
                    Write-Output "Updating SqlCmdVariable name: $name  value: $value";
                    $SqlCmdVariableNode.Value = $value;
                }
            }
        }
        $DacPacUpdatedProfilePath = "$DacPacFolder\$Database.deploy.publish.xml";
        $DacPacDacPublishProfile.Save($DacPacUpdatedProfilePath);
        Write-Output "Updated DacPublishProfile   : $DacPacUpdatedProfilePath";

        Write-Output "Following output generated by SqlPackage.exe";
        Write-Output "==============================================================================";

		$global:lastexitcode = 0;

        if (!(Ping-SqlServer -Server $Server)) {
            throw "Server '$Server' does not exist!";
        } else {
            Write-Verbose "Publish-DacPac: Deploying database '$Database' to server '$Server' using DacPac '$DacPacName'"

            $ArgList = @(
                "/Action:Publish",
                "/SourceFile:$DacPacPath",
                "/Profile:$DacPacUpdatedProfilePath"
            );
            Invoke-ExternalCommand -Command "$SqlPackageExePath" -Arguments $ArgList;
        }
    } catch {
        Write-Error "Error: $_";
    }
}
