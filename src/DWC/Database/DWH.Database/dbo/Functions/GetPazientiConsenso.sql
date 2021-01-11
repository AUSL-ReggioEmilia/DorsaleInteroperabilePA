
CREATE FUNCTION [dbo].[GetPazientiConsenso]
/*
Ritorna l'ultimo consenso del paziente passato
I possibili valori ritornati sono:
	0	Consenso negato
	1	Consenso abilitato
	2	Consenso non presente
*/
   (@IdPaziente  uniqueidentifier) --questo deve essere un paziente attivo
RETURNS tinyint
AS
BEGIN
	
	DECLARE @bitAbilitato bit
	DECLARE @Ret tinyint
	
	SELECT TOP 1
		@bitAbilitato=Stato
	FROM 
		sac.PazientiConsensi
	WHERE 
		IdPaziente = @IdPaziente 
		AND Descrizione = 'Generico'
	ORDER BY DataStato DESC
			
	--Se NULL (record non trovato) ritorno 2
	IF @bitAbilitato is null
		SET @Ret = 2
	ELSE
		SET @Ret = CONVERT(tinyint, @bitAbilitato)

	RETURN @Ret
 
END
