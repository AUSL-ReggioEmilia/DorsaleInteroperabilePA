



CREATE PROCEDURE [ws2].[RefertiByPazienteFuzzy]
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
		@IdRuolo	uniqueidentifier=NULL
) WITH RECOMPILE
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertiByPazienteFuzzy
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
		Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista

	Creo tabella idpaziente attivi e fusi tramite union utilizzando la PazientiFusioni
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto
	MODIFICA ETTORE 2016-05-02: spostato all'esterno la ricerca dei figli dei pazienti root trovati
								(prestazioni migliori in caso di query distribuite)

	MODIFICA ETTORE 2016-05-12: Usa la nuova func  [sac].[OttienePazientiPerFuzzy]
	MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
*/

	SET NOCOUNT ON

	DECLARE @PazientiFuzzy TABLE (Id uniqueidentifier NOT NULL  PRIMARY KEY
								, IdPazienteAttivo UNIQUEIDENTIFIER, DallaData DATETIME)
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
	-- A questo punto la tabella temporanea @PazientiFuzzy contiene id paziente attivi
	--
	SELECT 	TOP (@Top)
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
		ws2.Referti AS Referti
		INNER JOIN @PazientiFuzzy PF
		 ON Referti.IdPaziente = PF.id
	
	WHERE	
		(DataReferto>= PF.DallaData OR PF.DallaData IS NULL)
		AND (DataReferto <= @AllaData OR @AllaData IS NULL)
		--
		-- Filtro per DataPartizione
		--
		AND (DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
		
	ORDER BY DataReferto DESC
		
	RETURN @@ERROR
END
