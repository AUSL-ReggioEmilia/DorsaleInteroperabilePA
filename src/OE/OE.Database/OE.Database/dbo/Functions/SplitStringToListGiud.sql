-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-05-14
-- Description:	Converte una stringa separata da virgole in una lista di Guid
-- =============================================
CREATE FUNCTION dbo.SplitStringToListGiud
(
@ListOfGuid varchar(max)
)
RETURNS 
@TableOfGuid TABLE ([Value] uniqueidentifier)
AS
BEGIN

	DECLARE @Buffer varchar(max) = @ListOfGuid
	DECLARE @Value varchar(50)
	DECLARE @Pos int

	SET @Buffer = LTRIM(RTRIM(@Buffer)) + ','
	SET @Pos = CHARINDEX(',', @Buffer, 1)

	IF REPLACE(@Buffer, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @Value = LTRIM(RTRIM(LEFT(@Buffer, @Pos - 1)))
			
			IF @Value <> ''
			BEGIN
				INSERT INTO @TableOfGuid ([Value]) VALUES ( CONVERT(UNIQUEIDENTIFIER, @Value) )
			END
			
			SET @Buffer = RIGHT(@Buffer, LEN(@Buffer) - @Pos)
			SET @Pos = CHARINDEX(',', @Buffer, 1)
		END
	END
	
	RETURN 
END