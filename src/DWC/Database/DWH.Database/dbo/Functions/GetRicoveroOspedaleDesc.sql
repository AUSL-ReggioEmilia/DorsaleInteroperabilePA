
CREATE FUNCTION [dbo].[GetRicoveroOspedaleDesc] (
	@OspedaleCodice AS VARCHAR(16), 
	@DefaultDesc AS VARCHAR(128)
)  
RETURNS VARCHAR(128) AS  
BEGIN 
--
-- La descrizione potrebbe dipendere anche dall'aziendaerogante?
--
	DECLARE @Ret AS VARCHAR(128)

	IF ISNULL(@DefaultDesc, '') = ''
	BEGIN
		SET @Ret = CASE @OspedaleCodice
				WHEN '1' THEN ''  --bisogna sentire per le decodifiche
				ELSE '' END	
	END
	ELSE
	BEGIN
		SET @Ret = @DefaultDesc
	END
	 
	RETURN @Ret

END



