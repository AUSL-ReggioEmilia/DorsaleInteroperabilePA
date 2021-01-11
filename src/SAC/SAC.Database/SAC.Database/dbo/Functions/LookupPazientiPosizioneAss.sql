CREATE FUNCTION [dbo].[LookupPazientiPosizioneAss](
	@Codice AS tinyint
	)
RETURNS VARCHAR(16)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(16)
	SELECT @Ret = Descrizione
		FROM PazientiPosizioneAss
		WHERE Codice = @Codice
	
	RETURN @Ret
END

