CREATE FUNCTION [dbo].[LookupIstatAslCodiceEsteso](
	@Codice AS varchar(3)
	, @CodiceComune AS varchar(6)
	)
RETURNS VARCHAR(6)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(6)
	SELECT @Ret = CodiceAslRegione + Codice
		FROM IstatAsl
		WHERE Codice = @Codice
			AND CodiceComune = @CodiceComune
	
	RETURN @Ret
END

