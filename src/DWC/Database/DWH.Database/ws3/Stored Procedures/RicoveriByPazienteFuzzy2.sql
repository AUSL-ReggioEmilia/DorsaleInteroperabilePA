


CREATE PROCEDURE [ws3].[RicoveriByPazienteFuzzy2]
(
	@idToken		UNIQUEIDENTIFIER
	, @MaxNumRow	INTEGER
	, @Ordinamento	VARCHAR(128)
	, @ByPassaConsenso	BIT		
	, @Cognome 		VARCHAR (64)= NULL
	, @Nome 		VARCHAR (64)= NULL
	, @DataNascita		DATETIME= NULL
	, @AnnoNascita		INT= NULL
	, @CodiceFiscale 	VARCHAR (16)= NULL
	, @CodiceSanitario	VARCHAR (12)= NULL
	, @Anagrafica 		VARCHAR (16)= NULL
	, @IdAnagrafica		VARCHAR (64)= NULL
	, @DallaData		DATETIME = NULL
	, @AllaData		DATETIME = NULL
) WITH RECOMPILE
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-24:
	Creo tabella idpaziente attivi e fusi tramite union utilizzando la PazientiFusioni

	MODIFICA SANDRO 2016-05-12: Usa la nuova func  [sac].[OttienePazientiPerFuzzy]
	MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
	CREATA VERSIONE 2 DA ETTORE 2016-10-17: Restituzione nuovi campi StatoCodice e StatoDescrizione al posto del campo Stato (equivalente a StatoDescrizione)
*/
	SET NOCOUNT ON
	DECLARE @PazientiFuzzy TABLE (Id uniqueidentifier NOT NULL  PRIMARY KEY
								, IdPazienteAttivo UNIQUEIDENTIFIER, DallaData DATETIME)
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
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	--
	-- Limitazione records restituiti da database
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Ricoveri') , 2000)	
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top 	
	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DallaDataPartizione DATETIME
	SELECT @DallaDataPartizione = dbo.OttieniFiltroRicoveriPerDataPartizione(@DallaData)
    -------------------------------------------------------------------------------------------------------------------------
	--  Ricerco i Pazienti per Anagrafica+Codice + Cognome+Nome+CF + Cognome+Nome+CS + Cognome+Nome+DN
	-------------------------------------------------------------------------------------------------------------------------
	INSERT INTO @PazientiFuzzy (Id, IdPazienteAttivo, DallaData)
		SELECT Id, COALESCE(FusioneId, ID)

			-- Calcolo la data in base al consenso
			, CASE WHEN @ByPassaConsenso = 1 THEN @Dalladata
				ELSE [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData) END

		FROM [sac].[OttienePazientiPerFuzzy](10000, @Cognome, @Nome, @DataNascita, @AnnoNascita
											,@CodiceFiscale, @CodiceSanitario, @Anagrafica, @IdAnagrafica)
	--		
	-- Restituisco i dati
	--
	SELECT TOP (@MaxNumRow)
		R.Id AS Id
		, R.DataInserimento
		, R.DataModifica
		 --NUOVO: Se ricovero o lista di attesa
		, R.Categoria
		, R.NumeroNosologico
		----------, NumeroNosologicoOrigine
		, R.AziendaErogante
		, R.SistemaErogante
		, R.RepartoAccettazioneCodice
		, R.RepartoAccettazioneDescr
		--RepartoCorrenteCodice, RepartoCorrenteDescr se in Dimissione sono vuoti
		, R.RepartoCorrenteCodice
		, R.RepartoCorrenteDescr
		--
		-- RepartoDimissioneCodice, RepartoDimissioneDescr sono valorizzati solo se in dimissione
		--
		, R.RepartoDimissioneCodice
		, R.RepartoDimissioneDescr
		, R.Diagnosi
		, R.TipoRicoveroCodice AS TipoEpisodioCodice
		, R.TipoRicoveroDescr AS TipoEpisodioDescr
		, R.DataAccettazione AS DataInizioEpisodio
		, R.DataTrasferimento
		, R.DataDimissione AS DataFineEpisodio
		--
		-- Stato del ricovero (prima era UltimoEventoDescr) 
		-- se "ricovero":		Accettazione, Trasferimento, Dimissione, Riapertura 
		-- se "prenotazione":	Apertura, Chiusura
		--
		, R.StatoCodice
		, R.StatoDescrizione
		--
		, R.SettoreCodice
		, R.SettoreDescr
		, R.LettoCodice
		--Dati del paziente
		, PF.IdPazienteAttivo AS IdPaziente
		--
		--Dati anagrafici: nei precedenti WS non venivano restituiti
		--
		, R.Cognome
		, R.Nome
		, R.CodiceFiscale
		, R.DataNascita
		, R.Sesso
		, R.ComuneNascita
		, R.CodiceSanitario
	FROM 
		ws3.Ricoveri AS R
		INNER JOIN @PazientiFuzzy PF
			 ON R.IdPaziente = PF.id
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
				([dbo].[CheckRicoveroOscuramenti](@IdRuolo, R.AziendaErogante, R.NumeroNosologico) = 1)
			)
		) 	
		--
		-- Filtro per DataPrescrizione (DINAMICO SUL CONSENSO)
		--
		AND	(R.DataAccettazione>= PF.DallaData OR PF.DallaData IS NULL) 
		AND (R.DataAccettazione <= @AllaData OR @AllaData IS NULL)		
		--
		-- Filtro per DataPartizione (STATICO)
		--
		AND (R.DataPartizione >= @DallaDataPartizione OR @DallaDataPartizione IS NULL) 

	ORDER BY 
	--Default
	CASE @Ordinamento WHEN '' THEN DataAccettazione END DESC
	--Ascendente	
	, CASE @Ordinamento WHEN 'Id@ASC' THEN R.Id END ASC
	, CASE @Ordinamento WHEN 'DataInserimento@ASC' THEN R.DataInserimento END ASC	
	, CASE @Ordinamento WHEN 'DataModifica@ASC' THEN R.DataModifica END ASC		
	, CASE @Ordinamento WHEN 'Categoria@ASC' THEN R.Categoria END ASC
	, CASE @Ordinamento WHEN 'NumeroNosologico@ASC' THEN R.NumeroNosologico END ASC
	, CASE @Ordinamento WHEN 'AziendaErogante@ASC' THEN R.AziendaErogante END ASC
	, CASE @Ordinamento WHEN 'SistemaErogante@ASC' THEN R.SistemaErogante END ASC
	, CASE @Ordinamento WHEN 'RepartoAccettazioneCodice@ASC' THEN R.RepartoAccettazioneCodice END ASC
	, CASE @Ordinamento WHEN 'RepartoAccettazioneDescr@ASC' THEN R.RepartoAccettazioneDescr END ASC	
	, CASE @Ordinamento WHEN 'RepartoCorrenteCodice@ASC' THEN R.RepartoCorrenteCodice END ASC
	, CASE @Ordinamento WHEN 'RepartoCorrenteDescr@ASC' THEN R.RepartoCorrenteDescr END ASC	
	, CASE @Ordinamento WHEN 'RepartoDimissioneCodice@ASC' THEN R.RepartoDimissioneCodice END ASC
	, CASE @Ordinamento WHEN 'RepartoDimissioneDescr@ASC' THEN R.RepartoDimissioneDescr END ASC
	, CASE @Ordinamento WHEN 'Diagnosi@ASC' THEN R.Diagnosi END ASC	
	, CASE @Ordinamento WHEN 'TipoEpisodioCodice@ASC' THEN R.TipoRicoveroCodice END ASC
	, CASE @Ordinamento WHEN 'TipoEpisodioDescr@ASC' THEN R.TipoRicoveroDescr END ASC
	, CASE @Ordinamento WHEN 'DataInizioEpisodio@ASC' THEN R.DataAccettazione END ASC
	, CASE @Ordinamento WHEN 'DataTrasferimento@ASC' THEN R.DataTrasferimento END ASC	
	, CASE @Ordinamento WHEN 'DataFineEpisodio@ASC' THEN R.DataDimissione END ASC
	, CASE @Ordinamento WHEN 'StatoCodice@ASC' THEN R.StatoCodice END ASC	
	, CASE @Ordinamento WHEN 'StatoDescrizione@ASC' THEN R.StatoDescrizione END ASC	
	, CASE @Ordinamento WHEN 'SettoreCodice@ASC' THEN R.SettoreCodice END ASC
	, CASE @Ordinamento WHEN 'SettoreDescr@ASC' THEN R.SettoreDescr END ASC
	, CASE @Ordinamento WHEN 'LettoCodice@ASC' THEN R.LettoCodice END ASC
	, CASE @Ordinamento WHEN 'IdPaziente@ASC' THEN PF.IdPazienteAttivo END ASC
	, CASE @Ordinamento WHEN 'Cognome@ASC' THEN R.Cognome END ASC
	, CASE @Ordinamento WHEN 'Nome@ASC' THEN R.Nome END ASC
	, CASE @Ordinamento WHEN 'CodiceFiscale@ASC' THEN R.CodiceFiscale END ASC
	, CASE @Ordinamento WHEN 'DataNascita@ASC' THEN R.DataNascita END ASC
	, CASE @Ordinamento WHEN 'Sesso@ASC' THEN R.Sesso END ASC
	, CASE @Ordinamento WHEN 'ComuneNascita@ASC' THEN R.ComuneNascita END ASC
	, CASE @Ordinamento WHEN 'CodiceSanitario@ASC' THEN R.CodiceSanitario END ASC
	--Discendente	
	, CASE @Ordinamento WHEN 'Id@DESC' THEN R.Id END DESC
	, CASE @Ordinamento WHEN 'DataInserimento@DESC' THEN R.DataInserimento END DESC	
	, CASE @Ordinamento WHEN 'DataModifica@DESC' THEN R.DataModifica END DESC		
	, CASE @Ordinamento WHEN 'Categoria@DESC' THEN R.Categoria END DESC
	, CASE @Ordinamento WHEN 'NumeroNosologico@DESC' THEN R.NumeroNosologico END DESC
	, CASE @Ordinamento WHEN 'AziendaErogante@DESC' THEN R.AziendaErogante END DESC
	, CASE @Ordinamento WHEN 'SistemaErogante@DESC' THEN R.SistemaErogante END DESC
	, CASE @Ordinamento WHEN 'RepartoAccettazioneCodice@DESC' THEN R.RepartoAccettazioneCodice END DESC
	, CASE @Ordinamento WHEN 'RepartoAccettazioneDescr@DESC' THEN R.RepartoAccettazioneDescr END DESC	
	, CASE @Ordinamento WHEN 'RepartoCorrenteCodice@DESC' THEN R.RepartoCorrenteCodice END DESC
	, CASE @Ordinamento WHEN 'RepartoCorrenteDescr@DESC' THEN R.RepartoCorrenteDescr END DESC	
	, CASE @Ordinamento WHEN 'RepartoDimissioneCodice@DESC' THEN R.RepartoDimissioneCodice END DESC
	, CASE @Ordinamento WHEN 'RepartoDimissioneDescr@DESC' THEN R.RepartoDimissioneDescr END DESC
	, CASE @Ordinamento WHEN 'Diagnosi@DESC' THEN R.Diagnosi END DESC	
	, CASE @Ordinamento WHEN 'TipoEpisodioCodice@DESC' THEN R.TipoRicoveroCodice END DESC
	, CASE @Ordinamento WHEN 'TipoEpisodioDescr@DESC' THEN R.TipoRicoveroDescr END DESC
	, CASE @Ordinamento WHEN 'DataInizioEpisodio@DESC' THEN R.DataAccettazione END DESC
	, CASE @Ordinamento WHEN 'DataTrasferimento@DESC' THEN R.DataTrasferimento END DESC
	, CASE @Ordinamento WHEN 'DataFineEpisodio@DESC' THEN R.DataDimissione END DESC
	, CASE @Ordinamento WHEN 'StatoCodice@DESC' THEN R.StatoCodice END DESC
	, CASE @Ordinamento WHEN 'StatoDescrizione@DESC' THEN R.StatoDescrizione END DESC
	, CASE @Ordinamento WHEN 'SettoreCodice@DESC' THEN R.SettoreCodice END DESC
	, CASE @Ordinamento WHEN 'SettoreDescr@DESC' THEN R.SettoreDescr END DESC
	, CASE @Ordinamento WHEN 'LettoCodice@DESC' THEN R.LettoCodice END DESC
	, CASE @Ordinamento WHEN 'IdPaziente@DESC' THEN PF.IdPazienteAttivo END DESC
	, CASE @Ordinamento WHEN 'Cognome@DESC' THEN R.Cognome END DESC
	, CASE @Ordinamento WHEN 'Nome@DESC' THEN R.Nome END DESC
	, CASE @Ordinamento WHEN 'CodiceFiscale@DESC' THEN R.CodiceFiscale END DESC
	, CASE @Ordinamento WHEN 'DataNascita@DESC' THEN R.DataNascita END DESC
	, CASE @Ordinamento WHEN 'Sesso@DESC' THEN R.Sesso END DESC
	, CASE @Ordinamento WHEN 'ComuneNascita@DESC' THEN R.ComuneNascita END DESC
	, CASE @Ordinamento WHEN 'CodiceSanitario@DESC' THEN R.CodiceSanitario END DESC
END