

CREATE PROCEDURE [ws2].[RicoveriByNosologico]
(
	@NumeroNosologico VARCHAR(64)
	,@DallaData as datetime=null
	,@AllaData as datetime=null 
	,@IdRuolo uniqueidentifier=NULL
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveriByNosologico
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
		Restituisco anche il SistemaErogante
		
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
	-- Modifica Ettore 2012-11-29: limitazione record restituiti + ORDER BY DataAccettazioneDESC
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
	-- MODIFICA ETTORE 2017-10-09: MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
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
	-- Trovo i pazienti associati al nosologico: non c'è l'azienda, potrebbero essere differenti
	-- Devo trovarli per forza per determnare la data minima in base al consenso
	--
	DECLARE @Pazienti TABLE (Id uniqueidentifier NOT NULL  PRIMARY KEY, IdPazienteAttivo UNIQUEIDENTIFIER, DallaData DATETIME)
	INSERT INTO @Pazienti (Id, IdPazienteAttivo, DallaData) --valorizzo solo l'Id
	SELECT 
		R.IdPaziente AS Id	
		, COALESCE(PAZ.FusioneId, PAZ.Id)
		-- Calcolo la data in base al consenso
		, CASE WHEN @ByPassaConsenso = 1 THEN 
				ISNULL(@Dalladata, R.DataAccettazione)
			ELSE [dbo].[GetDataMinimaByConsensoAziendale](ISNULL(@Dalladata, R.DataAccettazione), PAZ.ConsensoAziendaleCodice, PAZ.ConsensoAziendaleData) 
			END AS DallaData
	FROM 
		store.RicoveriBase AS R
		OUTER APPLY [sac].[OttienePazientePerIdSac](R.IdPaziente) AS PAZ
	WHERE R.NumeroNosologico = @NumeroNosologico
	----------------------------------------------------------------------------------------------
	--PRINT '@Dalladata = ' + ISNULL(CONVERT(VARCHAR(20), @Dalladata, 120), 'NULL')
	--PRINT '@DataPartizioneDal  = ' + ISNULL(CONVERT(VARCHAR(20), @DataPartizioneDal , 120), 'NULL')
	--
	--
	--
	SELECT TOP (@Top)
		dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente
		,NumeroNosologico
		,AziendaErogante
		,SistemaErogante
		--
		-- Id del ricovero
		--
		,R.Id AS IdRicovero
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
		ws2.Ricoveri AS R
		inner join @Pazienti AS P
			ON R.IdPaziente = P.Id
	WHERE
		NumeroNosologico = @NumeroNosologico
		AND (P.DallaData IS NULL OR  P.DallaData <= DataAccettazione)
		AND (@AllaData IS NULL OR  DataAccettazione <= @AllaData)
		--
		-- Filtro per DataPartizione
		--
		AND (DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
	ORDER BY DataAccettazione DESC

	RETURN @@ERROR

END
