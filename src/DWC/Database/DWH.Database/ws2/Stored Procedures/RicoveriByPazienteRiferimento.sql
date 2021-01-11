


CREATE PROCEDURE [ws2].[RicoveriByPazienteRiferimento]
(
	@Anagrafica AS varchar (16),
	@IdAnagrafica AS varchar (64),
	@DallaData datetime = NULL,
	@AllaData datetime = NULL,
	@IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
BEGIN 
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveriByPazienteRiferimento
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
		Restituisco anche il SistemaErogante		
		Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista

	Restituisce la lista dei Ricoveri di un paziente passando i riferimenti ed un intervallo di date
	Limitazione record restituiti + ORDER BY DataAccettazioneDESC
	
	MODIFICA ETTORE 2015-11-24: Restituzione dei campi SettoreCodice, SettoreDescr, LettoCodice
	MODIFICA ETTORE 2015-12-02: Restituzione dei nuovi campi RepartoDimissioneCodice, RepartoDimissioneDescr
	
	In seguito a gestione "prenotazioni" modificato il codice che restituisce il campo "UltimoEventoDescr"

	ATTENZIONE:
	I dati restituiti nel campo "UltimoEventoDescr" NON POSSONO essere modificati in quanto utilizzati
	per descriminare fra ricoveri e liste di attesa
	MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
*/
	SET NOCOUNT ON
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
	-------------------------------------------------------------------------------------------------------------------------
	--  Ricerco in PazientiRiferimenti il Paziente per Anagrafica+Codice
	-------------------------------------------------------------------------------------------------------------------------
	--Ricavo subito l'idpaziente attivo dai riferimenti anagrafici
	DECLARE @IdPAziente UNIQUEIDENTIFIER
	SELECT @IdPAziente = dbo.GetPazientiIdByRiferimento(@Anagrafica, @IdAnagrafica)
	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DallaData)
	----------------------------------------------------------------------------------------------
	-- MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
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
	--
	-- Se non posso bypassare il consenso applico il filtro in base al consenso associato al paziente
	--
	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@Dalladata = [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPaziente
	END	
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	
	--	
	-- Restituisco il ricovero dai Ricoveri
	--
	SELECT TOP(@Top)
		--Restituisco l'idpaziente attivo		
		@IdPAziente AS IdPaziente
		,NumeroNosologico
		,AziendaErogante
		,SistemaErogante
		--
		-- Id del ricovero
		--
		,Ricoveri.Id AS IdRicovero
		,CAST( ISNULL(RepartoAccettazioneDescr,'') + ISNULL(NULLIF('(' + RepartoAccettazioneCodice + ')','()'), '') AS VARCHAR(128)) 
			AS RepartoRicoveroAccettazioneDescr
		,CASE WHEN DataDimissione IS NULL THEN
			CAST( ISNULL(RepartoDescr,'') + 
					ISNULL( NULLIF( '(' + RepartoCodice + ')' , '()') , '') AS VARCHAR(128))		
		ELSE
			''
		END AS RepartoRicoveroUltimoEventoDescr
		,Diagnosi
		,CAST(ISNULL(TipoRicoveroDescr,'') AS VARCHAR(128)) AS TipoEpisodioDescr
		,DataAccettazione AS DataInizioEpisodio
		,DataDimissione AS DataFineEpisodio
		--
		-- Descrizione dell'ultimo evento: 
		-- se "ricovero":		Accettazione, Trasferimento, Dimissione, Riapertura 
		-- se "prenotazione":	Apertura, Chiusura
		--
		,CASE 
			WHEN StatoCodice IN (0,1,2,3,4) THEN
				CASE WHEN StatoCodice = 2 THEN
					CAST('Trasferimento' AS VARCHAR(64))
				ELSE
					CAST(ISNULL(StatoDescr,'') AS VARCHAR(64))
				END
			WHEN StatoCodice IN (20,21,23) THEN --Prenotazione Aperta
				CAST('Apertura' AS VARCHAR(64))
			WHEN StatoCodice IN (22,24) THEN --Prenotazione Chiusa
				CAST('Chiusura' AS VARCHAR(64))
			ELSE
				CAST('' AS VARCHAR(64))
	 		END AS UltimoEventoDescr
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		,Oscuramenti
		--
		-- Nuovi campi: SettoreCodice, SettoreDescr, LettoCodice
		--
		,SettoreCodice, SettoreDescr, LettoCodice	
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
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON Ricoveri.IdPaziente = Pazienti.Id
	WHERE
		(@DallaData IS NULL OR  @DallaData <= DataAccettazione)
		AND (@AllaData IS NULL OR  DataAccettazione <= @AllaData)	
		--
		-- Filtro per DataPartizione
		--
		AND (DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
		
	ORDER BY DataAccettazione DESC
	
	RETURN @@ERROR

	SET NOCOUNT OFF
	
END



