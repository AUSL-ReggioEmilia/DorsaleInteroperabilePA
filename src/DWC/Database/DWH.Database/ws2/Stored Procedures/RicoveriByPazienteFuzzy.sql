


CREATE PROCEDURE [ws2].[RicoveriByPazienteFuzzy]
(
	@Cognome 		varchar (64)= NULL,	
	@Nome 		varchar (64)= NULL,
	@DataNascita		DateTime= NULL,
	@CodiceFiscale 	varchar (16)= NULL,
	@CodiceSanitario	varchar (12)= NULL,
	@Anagrafica 		varchar (16)= NULL,
	@IdAnagrafica		varchar (64)= NULL,
	@DallaData		datetime = NULL,
	@AllaData		datetime = NULL,
	@IdRuolo UNIQUEIDENTIFIER = NULL
) WITH RECOMPILE
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveriByPazienteFuzzy
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
		Restituisco anche il SistemaErogante		
		Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista

	Creo tabella idpaziente attivi e fusi tramite union utilizzando la PazientiFusioni
	Limitazione record restituiti + ORDER BY DataAccettazioneDESC
	
	MODIFICA ETTORE 2015-11-24: Restituzione dei campi SettoreCodice, SettoreDescr, LettoCodice	
	MODIFICA ETTORE 2015-12-02: Restituzione dei nuovi campi RepartoDimissioneCodice, RepartoDimissioneDescr
	
	In seguito a gestione "prenotazioni" modificato il codice che restituisce il campo "UltimoEventoDescr"

	ATTENZIONE:
	I dati restituiti nel campo "UltimoEventoDescr" NON POSSONO essere modificati in quanto utilizzati
	per descriminare fra ricoveri e liste di attesa
	
	MODIFICA ETTORE 2016-05-02: spostato all'esterno la ricerca dei figli dei pazienti root trovati
								(prestazioni migliori in caso di query distribuite)

	MODIFICA ETTORE 2016-05-12: Usa la nuova func  [sac].[OttienePazientiPerFuzzy]
	MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
*/
	SET NOCOUNT ON
	DECLARE @PazientiFuzzy TABLE (Id uniqueidentifier NOT NULL  PRIMARY KEY
								, IdPazienteAttivo UNIQUEIDENTIFIER, DallaData DATETIME)
	--
	-- Modifica Ettore 2012-11-29: limitazione record restituiti + ORDER BY DataAccettazione DESC
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Ricoveri') , 2000)	
	--
	-- Ricavo eventualmente la data minima dalle configurazioni
	--
	IF @DallaData IS NULL
	BEGIN 
		SET @DallaData = DATEADD(day, - ISNULL([dbo].[GetConfigurazioneInt] ('Ws2','RicoveriDaGiorni') , 3650), GETDATE())
	END 
	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DallaData)

	----------------------------------------------------------------------------------------------
	-- MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
	----------------------------------------------------------------------------------------------
	--
	-- Cerco eventuale attributo di bypass del consenso associato al ruolo
	-- 
	DECLARE @ByPassaConsenso BIT = 0
	IF @IdRuolo IS NULL
	BEGIN
		SET @ByPassaConsenso = 1
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT * FROM [dbo].[SAC_RuoliAccesso] WHERE (IdRuolo = @IdRuolo AND Accesso = 'ATTRIB@ACCES_NEC_CLIN'))
			SET @ByPassaConsenso = 1
	END
	-------------------------------------------------------------------------------------------------------------------------
	--  Ricerco i Pazienti per Anagrafica+Codice + Cognome+Nome+CF + Cognome+Nome+CS + Cognome+Nome+DN
	-------------------------------------------------------------------------------------------------------------------------
	INSERT INTO @PazientiFuzzy (Id, IdPazienteAttivo, DallaData)
		SELECT Id, COALESCE(FusioneId, ID)
			-- Calcolo la data in base al consenso
			, CASE WHEN @ByPassaConsenso = 1 THEN @Dalladata
				ELSE [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData) END
	FROM [sac].[OttienePazientiPerFuzzy](10000, @Cognome, @Nome, @DataNascita, NULL
												, @CodiceFiscale, @CodiceSanitario, @Anagrafica, @IdAnagrafica)
	--		
	-- Restituisco il ricovero dai Ricoveri
	--
	SELECT TOP (@Top)
		 PF.IdPazienteAttivo AS IdPaziente
		,Ricoveri.NumeroNosologico
		,Ricoveri.AziendaErogante
		,Ricoveri.SistemaErogante
		--
		-- Id del ricovero
		--
		,Ricoveri.Id AS IdRicovero
		,CAST( ISNULL(Ricoveri.RepartoAccettazioneDescr,'') + ISNULL(NULLIF('(' + Ricoveri.RepartoAccettazioneCodice + ')','()'), '') AS VARCHAR(128)) 
			AS RepartoRicoveroAccettazioneDescr
		,CASE WHEN Ricoveri.DataDimissione IS NULL THEN
			CAST( ISNULL(Ricoveri.RepartoDescr,'') + 
					ISNULL( NULLIF( '(' + Ricoveri.RepartoCodice + ')' , '()') , '') AS VARCHAR(128))		
		ELSE
			''
		END AS RepartoRicoveroUltimoEventoDescr
		,Ricoveri.Diagnosi
		,CAST(ISNULL(Ricoveri.TipoRicoveroDescr,'') AS VARCHAR(128)) AS TipoEpisodioDescr
		,Ricoveri.DataAccettazione AS DataInizioEpisodio
		,Ricoveri.DataDimissione AS DataFineEpisodio
		--
		-- Descrizione dell'ultimo evento: 
		-- se "ricovero":		Accettazione, Trasferimento, Dimissione, Riapertura 
		-- se "prenotazione":	Apertura, Chiusura
		--
		,CASE 
			WHEN Ricoveri.StatoCodice IN (0,1,2,3,4) THEN
				CASE WHEN Ricoveri.StatoCodice = 2 THEN
					CAST('Trasferimento' AS VARCHAR(64))
				ELSE
					CAST(ISNULL(Ricoveri.StatoDescr,'') AS VARCHAR(64))
				END
			WHEN Ricoveri.StatoCodice IN (20,21,23) THEN --Prenotazione Aperta
				CAST('Apertura' AS VARCHAR(64))
			WHEN Ricoveri.StatoCodice IN (22,24) THEN --Prenotazione Chiusa
				CAST('Chiusura' AS VARCHAR(64))
			ELSE
				CAST('' AS VARCHAR(64))
	 		END AS UltimoEventoDescr		
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		,Ricoveri.Oscuramenti
		--
		-- Nuovi campi: SettoreCodice, SettoreDescr, LettoCodice
		--
		,Ricoveri.SettoreCodice, Ricoveri.SettoreDescr, Ricoveri.LettoCodice		
		--
		-- Nuovi campi: RepartoDimissioneCodice, RepartoDimissioneDescr
		-- Li restituisco solo se il ricovero è in dimissione
		--
		, CASE WHEN NOT DataDimissione IS NULL THEN
			RepartoCodice
		ELSE
			CAST(NULL AS VARCHAR(16))
		END AS RepartoDimissioneCodice
		, CASE WHEN NOT DataDimissione IS NULL THEN
			RepartoDescr
		ELSE
			CAST(NULL AS VARCHAR(128))
		END AS RepartoDimissioneDescr
		
	FROM 
		ws2.Ricoveri AS Ricoveri
		INNER JOIN @PazientiFuzzy PF
		 ON Ricoveri.IdPaziente = PF.id
	WHERE
		(PF.DallaData IS NULL OR  PF.DallaData <= DataAccettazione)
		AND (@AllaData IS NULL OR  DataAccettazione <= @AllaData)
		--
		-- Filtro per DataPartizione
		--
		AND (DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
		
	ORDER BY DataAccettazione DESC

	RETURN @@ERROR
END

