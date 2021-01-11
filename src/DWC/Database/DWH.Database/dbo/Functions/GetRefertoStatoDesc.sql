
CREATE FUNCTION [dbo].[GetRefertoStatoDesc] (@RepartoErogante AS VARCHAR(64), 
											@StatoCodice AS VARCHAR(16), 
											@StatoDesc AS VARCHAR(128))  
RETURNS VARCHAR(128) AS  
/*
Funzione che ritorna la descrizione dello stato uniformato per tutti i dipartimentali

	0 = In corso
	1 = Completata
	2 = Variata dopo il completamento
	3 = Cancellata
*/

BEGIN 
 
DECLARE @Ret AS VARCHAR(128)

IF ISNULL(@StatoDesc, '') = ''
	BEGIN
	--
	-- Non c'è, la calcolo
	--
	SET @Ret = CASE @StatoCodice	WHEN '0' THEN 'In corso'
						WHEN '1' THEN 'Completata'
						WHEN '2' THEN 'Variata'
						WHEN '3' THEN 'Cancellata'
						ELSE '' END	
	END
ELSE
	BEGIN
	--
	-- Ritorno la desc passata
	--
	SET @Ret = @StatoDesc
	END
 
RETURN @Ret

END

