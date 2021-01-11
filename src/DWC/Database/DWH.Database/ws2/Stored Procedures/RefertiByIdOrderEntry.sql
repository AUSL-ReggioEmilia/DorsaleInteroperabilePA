



CREATE PROCEDURE [ws2].[RefertiByIdOrderEntry]
(
	@IdOrderEntry as varchar(64),
	@IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertiByIdOrderEntry
		Restituito il campo XML Oscuramenti
	Restituisce la lista dei referti per @IdOrderEntry
	
	Limitazione record restituiti 
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto			

	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
	MODIFICA ETTORE 2018-01-23: Modificato il calcolo della DataAl per tenere conto degli @IdOrderEntry generati a fine anno
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @IdPaziente uniqueidentifier
	DECLARE @DataDal DATETIME
	DECLARE @DataAl DATETIME
	--
	-- Controllo correttezza formattazione IdOrderEntry [YYYY/nnnnnn]: YYYY deve essere un numero
	--
	DECLARE @Anno VARCHAR(4)
	SET @Anno = LEFT(@IdOrderEntry, 4)
	IF ISNUMERIC(@Anno) <> 1
	BEGIN
		RAISERROR('L''IdOrderEntry non è formattato correttamente.', 16, 1)
		RETURN
	END 
	--
	-- Calcolo @DataDal e @DataAl 
	--
	SET @DataDal = CAST(CAST(@Anno AS VARCHAR(4)) + '-01-01' AS DATETIME)
	SET @DataAl = DATEADD(month, 18, @DataDal)	--aggiungo 18 mesi (un anno e mezzo) alla @DataDal per tenere conto degli @IdOrderEntry generati a fine anno
	--
	-- Limitazione record restituiti 
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)	
	--
	-- Cerco nella RefertiBase il/i pazienti associati all'IdOrderEntry
	--
	SELECT TOP 1 @IdPaziente = IdPaziente
	FROM ws2.Referti
	WHERE IdOrderEntry = @IdOrderEntry
		AND IdPaziente <> '00000000-0000-0000-0000-000000000000'	
		
	--Traslo l'idpaziente nell'idpaziente attivo		
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--PRINT '@IdPaziente = ' + CAST(@IdPaziente AS VARCHAR(40))

	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DataPartizioneDal DATETIME
	SET @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DataDal)
	--PRINT '@DataPartizioneDal = ' + ISNULL(CONVERT(VARCHAR(20), @DataPartizioneDal , 120), 'NULL')

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
			@DataDal = [dbo].[GetDataMinimaByConsensoAziendale](@DataDal, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPaziente
	END	

	--PRINT '@ByPassaConsenso = ' + CAST(@ByPassaConsenso AS VARCHAR(10))
	--PRINT '@DataDal = ' + ISNULL(CONVERT(VARCHAR(20), @DataDal, 120), 'NULL')
	
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
		R.Id,
		R.AziendaErogante,
		R.SistemaErogante,
		R.RepartoErogante,
		R.DataReferto,
		R.NumeroReferto,
		R.NumeroNosologico,
		R.NumeroPrenotazione,
		R.Cognome,
		R.Nome,
		R.CodiceFiscale,
		R.DataNascita,
		R.ComuneNascita,
		R.RepartoRichiedenteCodice,
		R.RepartoRichiedenteDescr,
		R.StatoRichiestaCodice,
		R.StatoRichiestaDescr,
		R.TipoRichiestaCodice,
		R.TipoRichiestaDescr,
		R.Anteprima,
		--Questo lo restituisco cosi perchè prima c'era un CAST a VARCHAR(128), per compatibilità
		CAST(R.SpecialitaErogante AS VARCHAR(128)) AS SpecialitaErogante,
		R.DataEvento,
		R.Firmato,
		R.Oscuramenti
	FROM	
		ws2.Referti as R
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON R.IdPaziente = Pazienti.Id		
	WHERE 
		IdOrderEntry = @IdOrderEntry 
		--
		-- Filtro in base alla data e alla data di partizione
		--
		AND (R.DataEvento >= @DataDal) AND (R.DataEvento <= @DataAl) 
		AND (R.DataPartizione >= @DataPartizioneDal )

	ORDER BY DataReferto DESC

	RETURN @@ERROR

END

