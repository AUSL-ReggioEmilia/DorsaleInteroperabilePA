CREATE FUNCTION [dbo].[LookupIstatRegioni](
	@Codice AS varchar(2)
	)
RETURNS VARCHAR(128)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(128)
	SELECT @Ret = Nome
		FROM IstatRegioni
		WHERE Codice = @Codice
	
	RETURN @Ret
END

