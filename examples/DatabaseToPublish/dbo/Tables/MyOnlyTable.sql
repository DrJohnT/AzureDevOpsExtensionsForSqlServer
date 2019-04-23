CREATE TABLE dbo.MyOnlyTable
(
	MyOnlyTableId INT NOT NULL  identity(1,1),
	MyOnlyColumn nvarchar(100) not null,	
	MyOnlyValue money not null, 
	InMyCurrency char(3) not null,
    CONSTRAINT PK_MyOnlyTable PRIMARY KEY (MyOnlyTableId),  -- always name your PKs!
)
