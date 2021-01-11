CREATE  PROCEDURE [dbo].[SrvcStampeSottoscrizioniCodaDocumentiByIdReferto]
(
@IdStampeSottoscrizione uniqueidentifier,
@IdReferto uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Prelevo eventuali record già presenti nella coda dei documenti che si riferiscono
	-- a stampe del medesimo referto da usare per confrontarli con gli allegati da inserire
	-- nella tabella StampeSottoscrizioniDocumentiCoda
	--
/*
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
		StampeSottoscrizioniDocumentiCoda AS D --coda dei documenti
		INNER JOIN StampeSottoscrizioniCoda AS R --coda dei referti
			ON D.IdStampeSottoscrizioniCoda = R.Id
	WHERE
		(R.IdStampeSottoscrizioni = @IdStampeSottoscrizione)
		AND (R.IdReferto = @IdReferto)
*/
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
		StampeSottoscrizioniDocumentiCoda AS D --coda dei documenti
		INNER JOIN StampeSottoscrizioniCoda AS R --coda dei referti
			ON D.IdStampeSottoscrizioniCoda = R.Id
		INNER JOIN  (
			SELECT 
				 R.IdStampeSottoscrizioni, R.IdReferto, MAX(D.DataSottomissione) AS DataSottomissione
			FROM 
				StampeSottoscrizioniDocumentiCoda AS D --coda dei documenti
				INNER JOIN StampeSottoscrizioniCoda AS R --coda dei referti
					ON D.IdStampeSottoscrizioniCoda = R.Id
			WHERE
				(R.IdStampeSottoscrizioni = @IdStampeSottoscrizione)
				AND (R.IdReferto = @IdReferto)
			GROUP BY
				 R.IdStampeSottoscrizioni ,R.IdReferto
			) AS TAB
			ON R.IdStampeSottoscrizioni = TAB.IdStampeSottoscrizioni
				AND R.IdReferto = TAB.IdReferto
				AND D.DataSottomissione = TAB.DataSottomissione
	WHERE 
		(R.IdStampeSottoscrizioni = @IdStampeSottoscrizione)
		AND (R.IdReferto = @IdReferto)

--
-- Si deve prendere solo record della coda dei documenti che non sono andati in errore?
--

--
-- Si può aggiungere un ulteriore filtro sulla data per escludere 
-- stampe troppo vecchie ?
--

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDocumentiByIdReferto] TO [ExecuteService]
    AS [dbo];

