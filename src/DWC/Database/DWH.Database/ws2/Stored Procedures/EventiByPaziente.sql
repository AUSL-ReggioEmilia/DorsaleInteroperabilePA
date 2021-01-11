



CREATE PROCEDURE [ws2].[EventiByPaziente]
(
	@IdPazienti  uniqueidentifier,
	@DallaData datetime = NULL,
	@AllaData datetime = NULL,
	@IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2EventiByPaziente
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
	Note:
	Restituisce la lista degli eventi di un paziente per un intervallo di date
	Limitazione record restituiti + ORDER BY DataEvento DESC
	
	MODIFICA ETTORE 2015-07-24: traslazione dell’IdPaziente passato come parametro nell’IdPaziente Attivo	
	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
*/
	SET NOCOUNT ON
	--
	-- Modifica Ettore 2012-11-29: limitazione record restituiti + ORDER BY DataEvento DESC
	--
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
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPazienti = dbo.GetPazienteAttivoByIdSac(@IdPazienti)

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
	-- Se non posso bypassare il consenso applico il filtro in base al consenso associato al paziente
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
	--
	--
	SELECT  TOP (@Top)
		Eventi.Id,
		AziendaErogante,
		SistemaErogante,
		ISNULL(RepartoErogante,'') AS RepartoErogante, --gestione NULL
		DataEvento,
		TipoEventoCodice,
		TipoEventoDescr,
		NumeroNosologico,
		ISNULL(TipoEpisodio,'') AS TipoEpisodio,--gestione dei null
		TipoEpisodioDescr, --supporta il null
		Cognome,
		Nome,
		CodiceFiscale,
		DataNascita,
		ComuneNascita,
		ISNULL(RepartoCodice,'') AS RepartoCodice, --gestione dei null
		ISNULL(RepartoDescr,'') AS RepartoDescr, --gestione dei null
		Diagnosi,--supporta il null
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		Oscuramenti
	FROM	
		ws2.Eventi
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON Eventi.IdPaziente = Pazienti.Id	
	WHERE	
		(DataEvento >= @DallaData OR @DallaData IS NULL)
		AND (DataEvento <= @AllaData OR @AllaData IS NULL)
		--
		-- Filtro per DataPartizione
		--
		AND (DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
		
	ORDER BY DataEvento DESC

	RETURN @@ERROR

END

