
CREATE PROCEDURE [dbo].[FeprPrestazioniMatriceRisultato2]
(
	@IdPaziente as uniqueidentifier, 
	@DataDal as datetime=null, 
	@NumeroReferto as varchar(16)=null,
	@AziendaErogante as varchar(16)=null,
	@SistemaErogante as varchar(16)=null,
	@RepartoErogante as varchar(16)=null,
	@PrestazioneCodice as varchar(16)=null,
	@SezioneCodice as varchar(16)=null
)	WITH RECOMPILE
AS
BEGIN
/*
	Restituisce la lista dei risultati per paziente, data, sezione e prestazione.
	CREATA DA ETTORE 2014-06-11: Gestione DataEvento, DataEventoItaliano e ordinamento per DataEvento
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
	
	Ricavo DataPartizione di filtro dalla dal parametro @DataDal
*/
	SET NOCOUNT ON
	/*
	Toglie 6 mesi alla data odierna senza ora.
	*/
	SET @DataDal = ISNULL(@DataDal,  DATEADD(month, -6, CONVERT(varchar(8), GETDATE(), 112)))
	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DataDal)
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	--
	-- Leggo prima i referti
	--
	DECLARE @TableReferti as TABLE (Id uniqueidentifier)
    INSERT INTO @TableReferti(Id)
    SELECT R.Id
		FROM frontend.Referti AS R
			INNER JOIN @TablePazienti Pazienti
			ON R.IdPaziente = Pazienti.Id
	WHERE	
			-- Filtro per DataPartizione
			(R.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL) AND
			--Filtro su DataEvento
			(R.DataEvento >= @DataDal or @DataDal is null) AND
			(R.RepartoErogante like @RepartoErogante  or @RepartoErogante is null) AND
			(R.SistemaErogante = 'LAB') AND --non ha senso per gli altri sistemi eroganti
			(R.AziendaErogante like @AziendaErogante or @AziendaErogante is null) AND 
			(R.StatoRichiestaCodice <> 3) --No cancellati
	--
	--
	--
	SELECT	RP.IdRefertiBase,
			RP.DataReferto,
			RP.DataEvento,
			RP.NumeroReferto,
			CONVERT(VARCHAR(20), RP.DataEvento, 103) AS DataEventoItaliano,
			RP.SistemaErogante,
			RP.RepartoErogante,
			RP.IdPrestazioneBase AS IdPrestazioni,
			RP.SezioneCodice,
			LTRIM(RTRIM(RP.SezioneDescrizione)) + ' (' + RP.SezioneCodice + ')' as SezioneDescrizione,
			RP.PrestazioneCodice,
			RP.PrestazioneDescrizione,
			COALESCE( NULLIF(RP.Risultato, ''), RP.Commenti) AS Risultato,
			RP.SezionePosizione,
			RP.PrestazionePosizione,
			RP.Commenti,
			--PER COMPATIBILITA'
			'' AS RepartoRichiedenteRuoloVisualizzazione,
			'' AS RuoloVisualizzazioneRepartoRichiedente,
			'' AS RuoloVisualizzazioneSistemaErogante,
			1 AS TipoRecord
	FROM		
			store.RefertiPrestazioni AS RP
			INNER JOIN @TableReferti AS FiltroReferti
				ON RP.IdRefertiBase = FiltroReferti.Id
	WHERE	
			--
			-- Lascio Filtro per DataPartizione
			--
			(RP.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
			--Escludo ciò che è di batteriologia
			AND CAST(ISNULL(dbo.GetPrestazioniAttributo(RP.IdPrestazioneBase, Rp.DataPartizione, 'PrestTipo'),'C') as varchar(10)) <> 'M'
			AND (RP.PrestazioneCodice like @PrestazioneCodice  or @PrestazioneCodice is null)
			AND (RP.SezioneCodice like @SezioneCodice or @SezioneCodice is null)
			--Questo rende lenta la query, ma è inutile
			--AND (NOT RP.Risultato IS NULL or RP.Risultato <> '' or NOT RP.Commenti IS NULL or RP.Commenti <> '')
	ORDER BY 	
			TipoRecord, 
			--Ordinamento per DataEvento
			RP.DataEvento Desc, 			
			RP.NumeroReferto Desc
		
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprPrestazioniMatriceRisultato2] TO [ExecuteFrontEnd]
    AS [dbo];

