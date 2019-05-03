declare @myId int;
select @myId = ISNULL(MAX(MyOnlyTableId),0) + 1 from dbo.MyOnlyTable;

insert into dbo.MyOnlyTable
(
	MyOnlyTableId,
	MyOnlyColumn
)
values
(
	@myId,
	N'NewDataValue'
);