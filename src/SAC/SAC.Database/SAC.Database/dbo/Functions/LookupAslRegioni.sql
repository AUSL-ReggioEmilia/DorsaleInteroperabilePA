CREATE FUNCTION [dbo].[LookupAslRegioni](
	@Codice AS varchar(3)
	)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(64)
	SELECT @Ret = Nome
		FROM AslRegioni
		WHERE Codice = @Codice
	
	RETURN @Ret
END

