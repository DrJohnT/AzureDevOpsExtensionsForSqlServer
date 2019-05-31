-- *********************************************************************************************************
-- Drop all projects and environments in a SSISDB folder and then the folder itself
-- SQL Script written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/AzureDevOpsExtensionsForSqlServer/tree/master/extensions/DeploySsisProject
-- *********************************************************************************************************
declare @folder_name nvarchar(128) = N'$(SsisFolder)';
DECLARE @name sysname;
DECLARE @cmd nvarchar(1000);

declare @folderId int;
SELECT @folderId = folder_id FROM [$(SSISDB)].internal.folders WHERE [name] = @folder_name;

IF (@folderId is not null)
BEGIN
	print @folderId

	DECLARE keyCursor CURSOR FORWARD_ONLY FOR
	  SELECT [name] FROM [$(SSISDB)].internal.projects where folder_id = @folderId;

	OPEN keyCursor;

	FETCH NEXT FROM keyCursor INTO @name;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT @cmd = 'EXEC [$(SSISDB)].[catalog].[delete_project] @project_name=''' + @name +''', @folder_name=''' + @folder_name + '''';
		--PRINT @cmd;
		EXEC sp_executesql @cmd;
		FETCH NEXT FROM keyCursor INTO @name;
	END
	CLOSE keyCursor;
	DEALLOCATE keyCursor;

	DECLARE keyCursor CURSOR FORWARD_ONLY FOR
	  SELECT environment_name FROM [$(SSISDB)].internal.environments where folder_id = @folderId;

	OPEN keyCursor;

	FETCH NEXT FROM keyCursor INTO @name;

	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT @cmd = 'EXEC [$(SSISDB)].[catalog].[delete_environment] @environment_name=''' + @name +''', @folder_name=''' + @folder_name + '''';
		--PRINT @cmd;
		EXEC sp_executesql @cmd;
		FETCH NEXT FROM keyCursor INTO @name;
	END
	CLOSE keyCursor;
	DEALLOCATE keyCursor;

	EXEC [$(SSISDB)].[catalog].[delete_folder] @folder_name=@folder_name;
END