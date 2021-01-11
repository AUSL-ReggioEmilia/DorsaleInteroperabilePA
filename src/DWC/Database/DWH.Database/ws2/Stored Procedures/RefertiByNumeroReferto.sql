



CREATE PROCEDURE [ws2].[RefertiByNumeroReferto]
(
	@AziendaErogante as varchar(16),
	@SistemaErogante as varchar(16),
	@RepartoErogante as varchar(64)=null,
	@NumeroReferto	as varchar(16),
	@AnnoReferto int=null,
	--dati paziente
	@CodiceFiscale as varchar(16)=NULL,
	@IdPazienteEsterno as varchar(64)=NULL,
	@IdRuolo UNIQUEIDENTIFIER = NULL
)WITH RECOMPILE
AS
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertiByNumeroReferto
		Aggiunto calcolo filtro per data partizione e filtro per data partizione (basato su @AnnoReferto)
		Restituito il campo XML Oscuramenti
		Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista

	Restituisce la lista dei referti per paziente con i medesimi dati delle Ws2RefertiByXXXX
	Limitazione record restituiti + ORDER BY DataReferto DESC
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto

	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @ID_CONSENSO_DOSSIER_STORICO TINYINT = 3
	DECLARE @IdPaziente as uniqueidentifier
	DECLARE @DallaData AS DATETIME
	
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)	
	--
	-- Calcolo la data partizione di filtro (a partire da @AnnoReferto)
	--
	DECLARE @DataPartizioneDal DATETIME
	IF NOT @AnnoReferto IS NULL
	BEGIN
		SET @DallaData = CAST(CAST(@AnnoReferto AS VARCHAR(4)) + '-01-01' AS DATETIME)
	END 
	ELSE
	BEGIN
		--
		-- Ricavo eventualmente la data minima dalle configurazioni
		--
		SET @DallaData = DATEADD(day, - ISNULL([dbo].[GetConfigurazioneInt] ('Ws2','RefertiDaGiorni') , 3650), GETDATE())
	END
	--
	-- Imposto la data di partizione
	--
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaData)

	IF (@IdPaziente IS NULL) AND (ISNULL(@CodiceFiscale,'') <> '')
	BEGIN
		SELECT TOP 1 @IdPaziente = [Id]
		FROM [sac].[pazienti] 
		WHERE CodiceFiscale = @CodiceFiscale
		ORDER BY CodiceFiscale DESC, DataNascita DESC
	END
	IF (@IdPaziente IS NULL) AND (ISNULL(@IdPazienteEsterno,'') <> '')
	BEGIN
		SET @IdPaziente = dbo.GetPazientiIdByDipartimento( @IdPazienteEsterno)
	END
	--L'@IdPaziente trovato è già quello attivo

	----------------------------------------------------------------------------------------------
	-- MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
	----------------------------------------------------------------------------------------------
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

	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@Dalladata = [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPaziente
	END	
	----------------------------------------------------------------------------------------------
	--PRINT '@IdPaziente = ' + CAST(@IdPaziente AS VARCHAR(40))
	--PRINT '@Dalladata = ' + ISNULL(CONVERT(varchar(20) , @DallaData, 120) , 'NULL')
	--PRINT '@DataPartizioneDal = ' + ISNULL(CONVERT(varchar(20) , @DataPartizioneDal, 120) , 'NULL')

	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)	
	--
	-- Estrazione di tutti i referti legati al paziente
	--
	SELECT  TOP (@Top)
		Referti.Id,
		AziendaErogante,
		SistemaErogante,
		RepartoErogante,
		DataReferto,
		NumeroReferto,
		NumeroNosologico,
		NumeroPrenotazione,
		Cognome,
		Nome,
		CodiceFiscale,
		DataNascita,
		ComuneNascita,
		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr,
		StatoRichiestaCodice,
		StatoRichiestaDescr,
		TipoRichiestaCodice,
		TipoRichiestaDescr,
		Anteprima,
		--Questo lo restituisco cosi perchè prima c'era un CAST a VARCHAR(128), per compatibilità
		CAST(SpecialitaErogante AS VARCHAR(128)) AS SpecialitaErogante,
		DataEvento,
		Firmato,
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		Oscuramenti
	FROM	
		ws2.Referti as Referti
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON Referti.IdPaziente = Pazienti.Id		
			
	WHERE 
		(Referti.AziendaErogante = @AziendaErogante)
		AND (Referti.SistemaErogante = @SistemaErogante)
		AND (Referti.RepartoErogante = @RepartoErogante OR @RepartoErogante IS NULL)
		AND (Referti.NumeroReferto = @NumeroReferto)
		--AND (YEAR(Referti.DataReferto) = @AnnoReferto OR @AnnoReferto IS NULL) --questa non serve più avendo la variabile @DallaData 
		AND (Referti.DataReferto >= @DallaData OR @DallaData IS NULL)
		--
		-- Filtro per DataPartizione
		--
		AND (Referti.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
		
	ORDER BY DataReferto DESC

	RETURN @@ERROR

END




