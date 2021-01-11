CREATE FUNCTION [dbo].[LookupIstatProvince](
	@Codice AS varchar(3)
	)
RETURNS VARCHAR(2)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(2)
	SELECT @Ret = Sigla
		FROM IstatProvince
		WHERE Codice = @Codice
	
	RETURN @Ret
END

