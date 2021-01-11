
/*
Create date: 2019-02-25

Funzione che ritorna la descrizione dello stato uniformato per tutti i dipartimentali

	0 = Valido
	1 = Annullato
	2 = Cancellato
*/
CREATE FUNCTION [dbo].[GetEventoStatoDesc] (@StatoCodice AS VARCHAR(16))  
RETURNS VARCHAR(128) AS  

BEGIN 
 
	DECLARE @Ret AS VARCHAR(128)
	SET @Ret = CASE @StatoCodice	WHEN '0' THEN 'Valido'
						WHEN '1' THEN 'Annullato'
						WHEN '2' THEN 'Cancellato'
						ELSE '' END	
 
	RETURN @Ret

END