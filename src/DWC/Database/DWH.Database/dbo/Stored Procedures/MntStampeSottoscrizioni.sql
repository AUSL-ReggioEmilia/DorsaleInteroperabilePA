CREATE PROCEDURE [dbo].[MntStampeSottoscrizioni]
AS
BEGIN
/*
	LA CANCELLAZIONE DELLE SOTTOSCRIZIONI LA LASCIAMO FARE AI MANAGER
	LA MANTEINANCE CANCELLA SOLO DALLA CODA REFERTI E DALLA CODA DOCUMENTI
*/
--
-- Cancellazione periodica dei dati associati alle sottoscrizioni
--
	DECLARE @iDayOffset AS INT
	DECLARE @Now AS DATETIME
	SET @Now = GETDATE()
	--
	-- Dopo @iDayOffset giorni cancello le code che fanno riferimento a stampa con DataInserimento 
	-- precedente di @iDayOffset giorni rispetto alla data odierna
	--
	SET @iDayOffset = 120
	--
	-- Cancellazione della coda dei documenti
	--
	DELETE FROM StampeSottoscrizioniDocumentiCoda
	WHERE DataInserimento < DATEADD(day, -@iDayOffset, @Now)
	--
	-- Cancellazione della coda dei referti
	--
	DELETE R 
	FROM StampeSottoscrizioniCoda AS R
		 LEFT OUTER JOIN StampeSottoscrizioniDocumentiCoda AS D
			ON R.Id = D.IdStampeSottoscrizioniCoda
	WHERE 
		(D.IdStampeSottoscrizioniCoda IS NULL)
		AND (R.DataInserimento < DATEADD(day, -@iDayOffset, @Now)) --Fondamentale altrimenti cancello anche quelle in corso

END
