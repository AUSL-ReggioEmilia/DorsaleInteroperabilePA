



CREATE PROCEDURE [ws2].[EventiByPazienteRiferimenti]
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
		Sostituisce la dbo.Ws2EventiByPazienteRiferimenti
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
	Restituisce la lista degli Eventi di un paziente passando i riferimenti anagrafici 
	ed un intervallo di date
	Limitazione record restituiti + ORDER BY DataEvento DESC
	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
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
	------------------------------------------------------------------------
	--  Ricerco in PazientiRiferimenti il Paziente per Anagrafica+Codice
	------------------------------------------------------------------------
	--MODIFICA ETTORE 2012-09-11: ricavo subito l'idpaziente attivo dai riferimenti anagrafici
	DECLARE @IdPAziente UNIQUEIDENTIFIER
	SELECT @IdPAziente = dbo.GetPazientiIdByRiferimento(@Anagrafica, @IdAnagrafica)

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
		WHERE Id = @IdPAziente 
	END	

	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	
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
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON E.IdPaziente = Pazienti.Id		
	WHERE	
		--IdPaziente = @IdPAziente AND 
		(E.DataEvento >= @DallaData OR @DallaData IS NULL)
		AND (E.DataEvento <= @AllaData  OR @AllaData  IS NULL)
		--
		-- Filtro per DataPartizione
		--
		AND (E.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
	ORDER BY 
		E.DataEvento DESC
END
