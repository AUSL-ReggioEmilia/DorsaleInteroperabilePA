CREATE FUNCTION [dbo].[LookupIstatNazioni](
	@Codice AS varchar(3)
	)
RETURNS VARCHAR(128)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(128)
	SELECT @Ret = Nome
		FROM IstatNazioni
		WHERE Codice = @Codice
	
	RETURN @Ret
END

