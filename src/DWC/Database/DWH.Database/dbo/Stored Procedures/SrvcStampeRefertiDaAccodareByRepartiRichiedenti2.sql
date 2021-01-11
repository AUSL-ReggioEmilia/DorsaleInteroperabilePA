



CREATE PROCEDURE [dbo].[SrvcStampeRefertiDaAccodareByRepartiRichiedenti2]
(
	@IdStampeSottoscrizioni uniqueidentifier
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-07-02:
		Utilizza la vista dbo.StampeSottoscrizioniReferti che a sua volta utilizza la vista store.Referti
		filtrata allo stesso modo della vista frontend.Referti
*/
	DECLARE @DataDal as Datetime
	DECLARE @TipoReferti AS INTEGER
	
	SET @TipoReferti = NULL
	--
	-- Ricavo dati dalla sottoscrizione
	-- 
	SELECT 
		@DataDal = DataInizio 		
		, @TipoReferti = TipoReferti
	FROM 
		StampeSottoscrizioni 
	WHERE 
		ID = @IdStampeSottoscrizioni
	
	--
	-- Modifico la @DataDal se è trascorso troppo tempo rispetto a GetDate()
	-- Faccio query per referti la cui data è compresa fra una ora fa e adesso
	--
	IF GETDATE() > DATEADD(hh,1,@DataDal) 
	BEGIN
		SET @DataDal = DATEADD(hh, -1, GETDATE())
	END
	--
	-- Seleziono i referti
	--
	SELECT 
		SSR.IdReferto AS IdReferto
		, SSR.RefertiDataModifica AS DataModifica
		----SOLO PER DEBUG
		--, SSR.RefertiStatoRichiestaCodice		
		--, @TipoReferti AS TipoReferti
		--, SSR.RefertiConfidenziale AS Confidenziale
		--, SSR.RefertiOscuramento AS Oscuramento
		--, SSR.StampaConfidenziali
		--, SSR.StampaOscurati
	FROM 
		dbo.StampeSottoscrizioniReferti AS SSR
		LEFT OUTER JOIN StampeSottoscrizioniCoda
			ON	SSR.IdReferto = StampeSottoscrizioniCoda.IdReferto
				AND SSR.RefertiDataModifica = StampeSottoscrizioniCoda.DataModificaReferto
				AND StampeSottoscrizioniCoda.IdStampeSottoscrizioni = @IdStampeSottoscrizioni
		
	WHERE 
		SSR.IdStampeSottoscrizioni = @IdStampeSottoscrizioni
		AND (SSR.RefertiDataModifica >= @DataDal) AND (SSR.RefertiDataModifica  < GETDATE()) 
		AND (StampeSottoscrizioniCoda.Id IS NULL) --per cui non esiste un record nella coda
		--FILTRO PER TIPOLOGIA DI REFERTI
		AND
		(
			(@TipoReferti = 0 AND SSR.RefertiStatoRichiestaCodice IN (0,1,2)) --Tutti
			OR 
			(@TipoReferti IN(1,2) AND SSR.RefertiStatoRichiestaCodice IN (1,2)) --Solo i completati
		)
		--SSR.RefertiConfidenziale = 1 se il referto ha l'attributo confidenziale o ha la parola HIV nelle prestazioni
		AND
		(
			SSR.RefertiConfidenziale = 0
			OR 
			(SSR.StampaConfidenziali = 1 AND SSR.RefertiConfidenziale = 1 ) 
		)
		--SSR.RefertiOscuramento = 1 se il referto è soggetto ad oscuramenti diversi da quello per attributo Confidenziale e per parola HIV
		AND
		(
			SSR.RefertiOscuramento = 0
			OR
			(SSR.StampaOscurati = 1 AND SSR.RefertiOscuramento = 1)
		)		
		
	ORDER BY
		SSR.RefertiDataModifica DESC

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeRefertiDaAccodareByRepartiRichiedenti2] TO [ExecuteService]
    AS [dbo];

