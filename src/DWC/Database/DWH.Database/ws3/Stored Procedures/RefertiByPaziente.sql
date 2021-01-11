

CREATE PROCEDURE [ws3].[RefertiByPaziente]
(
	@IdToken		UNIQUEIDENTIFIER
	, @MaxNumRow	INTEGER
	, @Ordinamento	VARCHAR(128)
	, @ByPassaConsenso	BIT	
	, @IdPazienti	UNIQUEIDENTIFIER
	, @DallaData	DATETIME = NULL
	, @AllaData		DATETIME = NULL
	--Parametri aggiuntivi ad uso dell'accesso diretto
	, @SistemaErogante VARCHAR(16)=NULL
	, @RepartoErogante VARCHAR(64)=NULL
	, @RepartoRichiedenteCodice VARCHAR(64)=NULL
	, @NumeroNosologico VARCHAR(64)=NULL
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-15:
		Filtra su DataEvento
	MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
	MODIFICA SIMONEB 2017-07-11: utilizzo della nuova funzione LookUpTipoReferto2 al posto della LookUpTipoReferto.
	MODIFICA ETTORE 2017-10-30: Nuovi campi SoleDataInvio, SoleEsitoInvio
	Modify date: 2020-05-12 ETTORE : restituzione nuovi campi NumeroVersione,Avvertenze,Visualizzazioni (per task 7758, 7759, 5754)
									nessun ordinamento per questi campi sono degli attributi
	Modify date: ETTORE: 2020-06-12: Aggiunto l'attributo "Dwh@AvvertenzeSeverita"
*/
	SET NOCOUNT ON
	DECLARE @FlagVisualizzazioniDal DATETIME = '2020-06-01'
	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento ,'')
	--
	-- Verifico se al token è associato l'attibuto ATTRIB@VIEW_ALL
	--
	DECLARE @ViewAll as BIT=0
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
	--
	-- MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
	--
	IF @ByPassaConsenso = 1
	BEGIN
		IF NOT EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) WHERE Accesso = 'ATTRIB@ACCES_NEC_CLIN')
		BEGIN
			DECLARE @Errore NVARCHAR(4000);
			SET @Errore= N'[SecurityError]Il ruolo corrente non ha il permesso di bypassare il consenso.' 
			RAISERROR(@Errore, 16, 1)
			RETURN
		END
	END
	--
	-- Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	DECLARE @UtenteProcesso VARCHAR(64)
	SELECT @IdRuolo = IdRuolo, @UtenteProcesso = UtenteProcesso  FROM dbo.Tokens WHERE Id = @IdToken
	--
	-- Calcolo il nome dell'attributo $@Visualizzazioni@[UtenteProcesso]
	--
	DECLARE @NomeAttributo_Visualizzazioni VARCHAR(64) = [dbo].[NomeAttributoPersistenteVisionato](@UtenteProcesso, NULL)

	--
	-- Limitazione records restituiti da database
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPazienti = dbo.GetPazienteAttivoByIdSac(@IdPazienti)
	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DallaDataPartizione DATETIME
	SELECT @DallaDataPartizione = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaData)
	--
	-- Trovo i dati del consenso aziendale del paziente solo se non è stato forzato il consenso
	--
	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@Dalladata = [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPazienti
	END	
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienti)	
	--
	-- Restituzione dati
	--
	SELECT  TOP (@MaxNumRow)
		R.Id,
		R.IdEsterno,
		R.DataInserimento,
		R.DataModifica,
		R.AziendaErogante,
		R.SistemaErogante,
		R.RepartoErogante,
		CAST(CAST(TR.Id AS VARCHAR(40)) AS UNIQUEIDENTIFIER) AS IdTipoReferto, --cosi DataAdapter non crea key
		TR.Descrizione AS TipoRefertoDescrizione,
		R.DataReferto,
		R.NumeroReferto,
		R.NumeroNosologico,
		R.NumeroPrenotazione,
		R.IdOrderEntry,
		R.RepartoRichiedenteCodice,
		R.RepartoRichiedenteDescr,
		R.StatoRichiestaCodice,
		R.StatoRichiestaDescr,
		R.TipoRichiestaCodice,
		R.TipoRichiestaDescr,
		R.Anteprima,
		R.SpecialitaErogante,
		R.DataEvento,
		R.Firmato,
		R.PrioritaCodice,
		R.PrioritaDescr,
		R.IdPaziente,
		R.Cognome,
		R.Nome,
		R.CodiceFiscale,
		R.DataNascita,
		R.Sesso,
		R.ComuneNascita,
		R.CodiceSanitario,
		R.SoleEsitoInvio,
		R.SoleDataInvio,
		--Nuovi campi
		R.NumeroVersione,
		R.Avvertenze,
		CASE WHEN R.DataReferto >= @FlagVisualizzazioniDal THEN
			 CAST(dbo.GetRefertiAttributo2(R.Id, R.DataPartizione, @NomeAttributo_Visualizzazioni) AS INTEGER) 
		ELSE
			CAST(1 as INTEGER)
		END AS Visualizzazioni,
		AvvertenzeSeverita
	FROM	
		ws3.Referti AS R
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON R.IdPaziente = Pazienti.Id
		OUTER APPLY dbo.LookUpTipoReferto2(R.AziendaErogante, R.SistemaErogante, R.SpecialitaErogante) AS TR			
	WHERE	
		--
		-- Filtro per Sistema e Oscuramenti
		--
		(
			(@ViewAll = 1) 
			OR 
			(
				EXISTS( SELECT * FROM [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
						WHERE   R.SistemaErogante = SE.SistemaErogante AND  R.AziendaErogante = SE.AziendaErogante)
				AND 
				([dbo].[CheckRefertoOscuramenti] (@IdRuolo, R.Id, R.DataPartizione, R.AziendaErogante, R.SistemaErogante
												, R.StrutturaEroganteCodice, R.NumeroNosologico, R.RepartoRichiedenteCodice
												, R.RepartoErogante, R.Confidenziale ) = 1)
			)
		) 		
		--
		-- Filtro sui parametri aggiuntivi ad uso dell'accesso diretto
		--
		AND (R.SistemaErogante = @SistemaErogante OR @SistemaErogante IS NULL)
		AND (R.RepartoErogante = @RepartoErogante OR @RepartoErogante IS NULL)
		AND (R.RepartoRichiedenteCodice = @RepartoRichiedenteCodice OR @RepartoRichiedenteCodice IS NULL)
		AND (R.NumeroNosologico = @NumeroNosologico  OR @NumeroNosologico  IS NULL)
		--
		-- Filtro in base alla finetra temporale [@DallaData,@AllaData] e alla finestra sulla data di partizione [@DallaDataPartizione, @AllaDataPartizione]
		--
		AND	(R.DataEvento >= @DallaData OR @DallaData IS NULL)	AND (R.DataEvento <= @AllaData OR @AllaData IS NULL)		
		AND (R.DataPartizione >= @DallaDataPartizione )
		
	ORDER BY 
	--Default
	CASE @Ordinamento  WHEN '' THEN DataEvento END DESC
	--Ascendente	
	, CASE @Ordinamento  WHEN 'Id@ASC' THEN R.Id END ASC
	, CASE @Ordinamento  WHEN 'IdEsterno@ASC' THEN R.IdEsterno END ASC
	, CASE @Ordinamento  WHEN 'DataInserimento@ASC' THEN R.DataInserimento END ASC
	, CASE @Ordinamento  WHEN 'DataModifica@ASC' THEN R.DataModifica END ASC
	, CASE @Ordinamento  WHEN 'AziendaErogante@ASC' THEN R.AziendaErogante END ASC
	, CASE @Ordinamento  WHEN 'SistemaErogante@ASC' THEN R.SistemaErogante END ASC
	, CASE @Ordinamento  WHEN 'RepartoErogante@ASC' THEN RepartoErogante END ASC
	, CASE @Ordinamento  WHEN 'IdTipoReferto@ASC' THEN TR.Id END ASC	
	, CASE @Ordinamento  WHEN 'TipoRefertoDescrizione@ASC' THEN TR.Descrizione END ASC	
	, CASE @Ordinamento  WHEN 'DataReferto@ASC' THEN R.DataReferto END ASC 
	, CASE @Ordinamento  WHEN 'NumeroReferto@ASC' THEN R.NumeroReferto END ASC
	, CASE @Ordinamento  WHEN 'NumeroNosologico@ASC' THEN R.NumeroNosologico END ASC
	, CASE @Ordinamento  WHEN 'NumeroPrenotazione@ASC' THEN R.NumeroPrenotazione END ASC
	, CASE @Ordinamento  WHEN 'IdOrderEntry@ASC' THEN R.IdOrderEntry END ASC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteCodice@ASC' THEN R.RepartoRichiedenteCodice END ASC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteDescr@ASC' THEN R.RepartoRichiedenteDescr END ASC
	, CASE @Ordinamento  WHEN 'StatoRichiestaCodice@ASC' THEN R.StatoRichiestaCodice END ASC
	, CASE @Ordinamento  WHEN 'StatoRichiestaDescr@ASC' THEN R.StatoRichiestaDescr END ASC
	, CASE @Ordinamento  WHEN 'TipoRichiestaCodice@ASC' THEN R.TipoRichiestaCodice END ASC
	, CASE @Ordinamento  WHEN 'TipoRichiestaDescr@ASC' THEN R.TipoRichiestaDescr END ASC
	, CASE @Ordinamento  WHEN 'Anteprima@ASC' THEN R.Anteprima END ASC
	, CASE @Ordinamento  WHEN 'SpecialitaErogante@ASC' THEN R.SpecialitaErogante END ASC
	, CASE @Ordinamento  WHEN 'DataEvento@ASC' THEN R.DataEvento END ASC
	, CASE @Ordinamento  WHEN 'Firmato@ASC' THEN R.Firmato END ASC
	, CASE @Ordinamento  WHEN 'PrioritaCodice@ASC' THEN R.PrioritaCodice END ASC
	, CASE @Ordinamento  WHEN 'PrioritaDescr@ASC' THEN R.PrioritaDescr END ASC
	, CASE @Ordinamento  WHEN 'IdPaziente@ASC' THEN R.IdPaziente END ASC
	, CASE @Ordinamento  WHEN 'Cognome@ASC' THEN R.Cognome END ASC
	, CASE @Ordinamento  WHEN 'Nome@ASC' THEN R.Nome END ASC
	, CASE @Ordinamento  WHEN 'CodiceFiscale@ASC' THEN R.CodiceFiscale END ASC
	, CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN R.DataNascita END ASC
	, CASE @Ordinamento  WHEN 'Sesso@ASC' THEN R.Sesso END ASC
	, CASE @Ordinamento  WHEN 'ComuneNascita@ASC' THEN R.ComuneNascita END ASC
	, CASE @Ordinamento  WHEN 'CodiceSanitario@ASC' THEN R.CodiceSanitario END ASC
	, CASE @Ordinamento  WHEN 'SoleEsitoInvio@ASC' THEN R.SoleEsitoInvio END ASC
	, CASE @Ordinamento  WHEN 'SoleDataInvio@ASC' THEN R.SoleDataInvio END ASC
    --Discendente	
	, CASE @Ordinamento  WHEN 'Id@DESC' THEN R.Id END DESC
	, CASE @Ordinamento  WHEN 'IdEsterno@DESC' THEN R.IdEsterno END DESC
	, CASE @Ordinamento  WHEN 'DataInserimento@DESC' THEN R.DataInserimento END DESC
	, CASE @Ordinamento  WHEN 'DataModifica@DESC' THEN R.DataModifica END DESC
	, CASE @Ordinamento  WHEN 'AziendaErogante@DESC' THEN R.AziendaErogante END DESC
	, CASE @Ordinamento  WHEN 'SistemaErogante@DESC' THEN R.SistemaErogante END DESC
	, CASE @Ordinamento  WHEN 'RepartoErogante@DESC' THEN R.RepartoErogante END DESC
	, CASE @Ordinamento  WHEN 'IdTipoReferto@DESC' THEN TR.Id END DESC
	, CASE @Ordinamento  WHEN 'TipoRefertoDescrizione@DESC' THEN TR.Descrizione END DESC
	, CASE @Ordinamento  WHEN 'DataReferto@DESC' THEN R.DataReferto END DESC 
	, CASE @Ordinamento  WHEN 'NumeroReferto@DESC' THEN R.NumeroReferto END DESC
	, CASE @Ordinamento  WHEN 'NumeroNosologico@DESC' THEN R.NumeroNosologico END DESC
	, CASE @Ordinamento  WHEN 'NumeroPrenotazione@DESC' THEN R.NumeroPrenotazione END DESC
	, CASE @Ordinamento  WHEN 'IdOrderEntry@DESC' THEN R.IdOrderEntry END DESC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteCodice@DESC' THEN R.RepartoRichiedenteCodice END DESC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteDescr@DESC' THEN R.RepartoRichiedenteDescr END DESC
	, CASE @Ordinamento  WHEN 'StatoRichiestaCodice@DESC' THEN R.StatoRichiestaCodice END DESC
	, CASE @Ordinamento  WHEN 'StatoRichiestaDescr@DESC' THEN R.StatoRichiestaDescr END DESC
	, CASE @Ordinamento  WHEN 'TipoRichiestaCodice@DESC' THEN R.TipoRichiestaCodice END DESC
	, CASE @Ordinamento  WHEN 'TipoRichiestaDescr@DESC' THEN R.TipoRichiestaDescr END DESC
	, CASE @Ordinamento  WHEN 'Anteprima@DESC' THEN R.Anteprima END DESC
	, CASE @Ordinamento  WHEN 'SpecialitaErogante@DESC' THEN R.SpecialitaErogante END DESC
	, CASE @Ordinamento  WHEN 'DataEvento@DESC' THEN R.DataEvento END DESC
	, CASE @Ordinamento  WHEN 'Firmato@DESC' THEN R.Firmato END DESC
	, CASE @Ordinamento  WHEN 'PrioritaCodice@DESC' THEN R.PrioritaCodice END DESC
	, CASE @Ordinamento  WHEN 'PrioritaDescr@DESC' THEN R.PrioritaDescr END DESC
	, CASE @Ordinamento  WHEN 'IdPaziente@DESC' THEN R.IdPaziente END DESC
	, CASE @Ordinamento  WHEN 'Cognome@DESC' THEN R.Cognome END DESC
	, CASE @Ordinamento  WHEN 'Nome@DESC' THEN R.Nome END DESC
	, CASE @Ordinamento  WHEN 'CodiceFiscale@DESC' THEN R.CodiceFiscale END DESC
	, CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN R.DataNascita END DESC
	, CASE @Ordinamento  WHEN 'Sesso@DESC' THEN R.Sesso END DESC
	, CASE @Ordinamento  WHEN 'ComuneNascita@DESC' THEN R.ComuneNascita END DESC
	, CASE @Ordinamento  WHEN 'CodiceSanitario@DESC' THEN R.CodiceSanitario END DESC
	, CASE @Ordinamento  WHEN 'SoleEsitoInvio@DESC' THEN R.SoleEsitoInvio END DESC
	, CASE @Ordinamento  WHEN 'SoleDataInvio@DESC' THEN R.SoleDataInvio END DESC
            
END