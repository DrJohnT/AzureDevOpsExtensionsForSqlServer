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
	N'$(NewDataValue1)'
),
(
	@myId + 1,
	N'$(NewDataValue2)'
),
(
	@myId + 2,
	N'$(NewDataValue3)'
);
