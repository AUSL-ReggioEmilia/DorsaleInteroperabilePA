CREATE FUNCTION [dbo].[GetIstatCodiceProvinciaByCodiceComune](
	@Codice AS varchar(6)
	)
RETURNS varchar(3)
AS
BEGIN
	DECLARE @Ret AS varchar(3)
	SELECT @Ret = CodiceProvincia
		FROM IstatComuni
		WHERE Codice = @Codice
	
	RETURN @Ret
END

