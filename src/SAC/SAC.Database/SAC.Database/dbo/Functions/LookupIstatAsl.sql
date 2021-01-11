CREATE FUNCTION [dbo].[LookupIstatAsl](
	@Codice AS varchar(3)
	, @CodiceComune AS varchar(6)
	)
RETURNS VARCHAR(128)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(128)
	SELECT @Ret = Nome
		FROM IstatAsl
		WHERE Codice = @Codice
			AND CodiceComune = @CodiceComune
	
	RETURN @Ret
END

