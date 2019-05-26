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
	N'$(MyDataValue)'
),
(
	@myId+1,
	N'$(MyDataValue2)'
);