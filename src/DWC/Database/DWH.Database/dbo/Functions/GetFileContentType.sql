
CREATE FUNCTION [dbo].[GetFileContentType] (@FileName AS varchar(255))  
RETURNS VARCHAR(50) AS  
BEGIN 

DECLARE @ContentType VARCHAR(50)
DECLARE @FileExt VARCHAR(10)
DECLARE @LastDot int

	SET @LastDot = PATINDEX('%.%', REVERSE(@FileName))
	IF @LastDot > 0 
		SET @FileExt = SUBSTRING(@FileName, LEN(@FileName)-(@LastDot-2), @LastDot-1)
	ELSE
		SET @FileExt = ''
	
	SELECT @ContentType = ContentType
	FROM dbo.FileContentType
	WHERE Extension = @FileExt
	
	IF @ContentType IS NULL
		SET @ContentType = 'application/' + @FileExt

	RETURN @ContentType
END

