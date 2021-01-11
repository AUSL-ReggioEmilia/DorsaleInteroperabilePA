CREATE FUNCTION [dbo].[LookupIstatComuni](
	@Codice AS varchar(6)
	)
RETURNS VARCHAR(128)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(128)
	SELECT @Ret = Nome
		FROM IstatComuni
		WHERE Codice = @Codice
	
	RETURN @Ret
END

