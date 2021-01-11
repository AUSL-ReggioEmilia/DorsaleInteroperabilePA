
CREATE PROCEDURE [dbo].[SrvcStampeSottoscrizioniCodaDocumentiLista]
(
@IdStampeSottoscrizione uniqueidentifier
)
AS
BEGIN
/*
StatoStampa:
		DaSottomettere = 1
        Sottomessa = 2
        Terminata = 3
*/
--
-- Modifica Ettore 2013-04-22: modificato il tempo di attesa da 60 a 10 minuti 
--
	SET NOCOUNT ON;
	--
	-- Se dopo un tempo T la stampa è ancora nello stato 2 scrivo errore
	-- 
	DECLARE @T_Min AS INTEGER
	SET @T_Min = 10 --60
	UPDATE StampeSottoscrizioniDocumentiCoda
		SET Errore = 'Dopo 10 min. è impossibile determinare lo stato della stampa!'
			,DataModifica=GETDATE()
	FROM StampeSottoscrizioniDocumentiCoda
			INNER JOIN StampeSottoscrizioniCoda
			ON StampeSottoscrizioniDocumentiCoda.IdStampeSottoscrizioniCoda = StampeSottoscrizioniCoda.ID
	WHERE
		(GETDATE() > DATEADD(minute, @T_Min, StampeSottoscrizioniDocumentiCoda.DataSottomissione))
		AND
		(StampeSottoscrizioniCoda.IdStampeSottoscrizioni = @IdStampeSottoscrizione)
		AND 
		(StampeSottoscrizioniDocumentiCoda.Stato = 2) --non terminato
		-- e non ci sono errori
		AND 
		(ISNULL(StampeSottoscrizioniDocumentiCoda.Errore,'') = '')

	--
	-- Prelevo i record per i quali si deve aggiornare lo stato della stampa
	--
	SELECT 
	   D.Id
      ,D.Ts
      ,D.DataInserimento
      ,D.DataModifica
      ,D.IdStampeSottoscrizioniCoda
      ,D.HashDocumento
      ,D.IdJob
      ,D.DataSottomissione
      ,D.Stato
      ,D.Errore
    FROM 
		StampeSottoscrizioniDocumentiCoda AS D
		INNER JOIN StampeSottoscrizioniCoda AS R
			ON D.IdStampeSottoscrizioniCoda = R.Id
	WHERE
		(R.IdStampeSottoscrizioni = @IdStampeSottoscrizione)
		AND 
		(D.Stato IN (1,2)) --non terminati
		-- e non ci sono errori
		AND 
		(ISNULL(D.Errore,'') = '')
	ORDER BY
		D.DataInserimento
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDocumentiLista] TO [ExecuteService]
    AS [dbo];

