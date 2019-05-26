declare @myId int;
select @myId = ISNULL(MAX(MyTableId),0) + 1 from dbo.MyTable;

insert into dbo.MyTable
(
	MyTableId,
	MyColumn
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
