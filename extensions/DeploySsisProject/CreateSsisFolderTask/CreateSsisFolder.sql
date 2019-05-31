-- SQLCmd Script to create an SSIS folder

declare @folder_name sysname = N'$(SsisFolder)';
declare @folder_description sysname = N'$(SsisFolderDescription)';

if not exists (
				  select
						1
				  from	[$(SSISDB)].internal.folders
				  where [name] = @folder_name
			  )
begin
	declare @folder_id bigint;

	-- create the folder
	exec [$(SSISDB)].[catalog].create_folder
		@folder_name = @folder_name,
		@folder_id = @folder_id output;

end;

-- update the folder's description
update
		[$(SSISDB)].internal.folders
set
		[description] = @folder_description
where	[name] = @folder_name;
