


CREATE PROCEDURE [ws2].[RefertiByPazienteRiferimenti]
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
		Sostituisce la dbo.Ws2RefertiByPazienteRiferimenti
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
	
	Ritorna la lista dei referti di un paziente passando i riferimenti ed un intervallo di date
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto
	MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
*/
	SET NOCOUNT ON
	--
	-- Modifica Ettore 2012-11-29: limitazione record restituiti + ORDER BY DataReferto DESC
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)	
	--
	-- Ricavo eventualmente la data minima dalle configurazioni
	--
	IF @DallaData IS NULL
	BEGIN 
		SET @DallaData = DATEADD(day, - ISNULL([dbo].[GetConfigurazioneInt] ('Ws2','RefertiDaGiorni') , 3650), GETDATE())
	END 
	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaData)
	-------------------------------------------------------------------------------------------------------------------------
	--  Ricerco in PazientiRiferimenti il Paziente per Anagrafica+Codice
	-------------------------------------------------------------------------------------------------------------------------
	--MODIFICA ETTORE 2012-09-11: ricavo subito l'idpaziente attivo dai riferimenti anagrafici
	DECLARE @IdPAziente UNIQUEIDENTIFIER
	SELECT @IdPAziente = dbo.GetPazientiIdByRiferimento(@Anagrafica, @IdAnagrafica)

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
			-- MODIFICA ETTORE 2014-06-18: Nuovi campi
			DataEvento,
			Firmato,
			Oscuramenti
	FROM	
		ws2.Referti as Referti
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON Referti.IdPaziente = Pazienti.Id
		
	WHERE	
		(DataReferto >= @DallaData OR @DallaData IS NULL)
		AND (DataReferto <= @AllaData OR @AllaData IS NULL)
		--
		-- Filtro per DataPartizione
		--
		AND (DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
	ORDER BY DataReferto DESC


END

