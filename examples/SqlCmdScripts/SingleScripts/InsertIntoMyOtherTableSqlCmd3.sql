declare @myId int;
select @myId = ISNULL(MAX(MyOtherTableId),0) + 1 from dbo.MyOtherTable;

insert into dbo.MyOtherTable
(
	MyOtherTableId,
	MyOtherColumn
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
