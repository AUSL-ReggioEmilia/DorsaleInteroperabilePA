


CREATE FUNCTION [dbo].[GetEventiTipoEpisodioDesc] (
	--i codici potrebbero essere uguali con diverso significato per diversi reparti !!!
	@RepartoErogante AS VARCHAR(64),  --non usata per ora 
	@StatoCodice AS VARCHAR(16), 
	@StatoDesc AS VARCHAR(128)
)  
RETURNS VARCHAR(128) AS  
/*
	Modifica Ettore 2013-03-01: nuova codifica OBI - Il connettore ADT fornisce per il tipo episodio OBI il codice B
	MODIFICA ETTORE 2016-09-08aggiunto nuovo codice TipoEpisodio 'A' (=Altro) per gestione nuovo sistema erogante EIM-ADTSTR
*/
BEGIN 
DECLARE @Ret AS VARCHAR(128)

	IF ISNULL(@StatoDesc, '') = ''
	BEGIN
		SET @Ret = CASE @StatoCodice	
				WHEN 'O' THEN 'Ricovero Ordinario'
				WHEN 'D' THEN 'Ricovero in Day Hospital'
				WHEN 'S' THEN 'Ricovero in Day Service'
				WHEN 'P' THEN 'Episodio di Pronto Soccorso'
				WHEN 'B' THEN 'OBI'
				----------- Nuovo TipoEpisodio per sistema 
				WHEN 'A' THEN 'Altro'
				ELSE '' END	
	END
	ELSE
	BEGIN
		SET @Ret = @StatoDesc
	END
	 
	RETURN @Ret

END

