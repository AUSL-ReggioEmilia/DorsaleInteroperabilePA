




CREATE PROCEDURE [ws2].[EventiByNosologico]
(
	@NumeroNosologico varchar(64),
	@DallaData datetime = NULL,
	@AllaData datetime = NULL,
	@IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
	/*
		CREATA DA ETTORE 2015-05-22:
			Sostituisce la dbo.Ws2EventiByNosologico
			Aggiunto calcolo filtro per data partizione e filtro per data partizione
			Restituito il campo XML Oscuramenti

		Note:
		Restituisce  la lista degli eventi relativi ad un Numero nosologico e per un intervallo di date
		Limitazione record restituiti + ORDER BY DataEvento DESC
		MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
									Nel caso @DallaData sia NULL la ricavo dalla data di accettazione del nosologico
	*/
	SET NOCOUNT ON
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Eventi') , 2000)	
	--
	-- Ricavo eventualmente la data minima dalle configurazioni
	--
	IF @DallaData IS NULL
	BEGIN 
		SET @DallaData = DATEADD(day, - ISNULL([dbo].[GetConfigurazioneInt] ('Ws2','EventiDaGiorni') , 3650), GETDATE())
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
	--Ricalcolo eventualmente la data di partizione
	IF @DataPartizioneDal IS NULL
		SELECT @DataPartizioneDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DallaData)
	----------------------------------------------------------------------------------------------
	--PRINT '@Dalladata = ' + ISNULL(CONVERT(VARCHAR(20), @Dalladata, 120), 'NULL')
	--PRINT '@DataPartizioneDal  = ' + ISNULL(CONVERT(VARCHAR(20), @DataPartizioneDal , 120), 'NULL')

	SELECT  TOP (@Top)
		E.Id,
		E.AziendaErogante,
		E.SistemaErogante,
		ISNULL(E.RepartoErogante,'') AS RepartoErogante, --gestione NULL
		E.DataEvento,
		E.TipoEventoCodice,
		E.TipoEventoDescr,
		E.NumeroNosologico,
		ISNULL(E.TipoEpisodio,'') AS TipoEpisodio,--gestione dei null
		E.TipoEpisodioDescr, --supporta il null
		E.Cognome,
		E.Nome,
		E.CodiceFiscale,
		E.DataNascita,
		E.ComuneNascita,
		ISNULL(E.RepartoCodice,'') AS RepartoCodice, --gestione dei null
		ISNULL(E.RepartoDescr,'') AS RepartoDescr, --gestione dei null
		E.Diagnosi,--supporta il null
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		E.Oscuramenti
	FROM	
		ws2.Eventi AS E
		inner join @Pazienti AS P
			ON E.IdPaziente = P.Id
	WHERE	
		E.NumeroNosologico = @NumeroNosologico
		--AND (E.DataEvento >= @DallaData OR @DallaData IS NULL)
		--Filtro in base alle date del consenso per paziente
		AND (E.DataEvento >= P.DallaData OR P.DallaData IS NULL)
		AND (E.DataEvento <= @AllaData OR @AllaData IS NULL)
		--
		-- Filtro per DataPartizione
		--
		AND (E.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
	ORDER BY 
		DataEvento DESC

	RETURN @@ERROR

END
