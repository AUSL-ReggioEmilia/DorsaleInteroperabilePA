


-- =============================================
-- Author:		Ettore
-- Create date: 2015-11-12
-- Modify sandro: 2016-05-12 Usa la nuova func  [sac].[OttienePazientiPerFuzzy]
--							Semplificata la parte relativa al filtro per @DataPartizione
-- Modify Ettore: 2016-09-01 - Ettore: Verifico che al ruolo sia associato il permesso di bypassare il consenso
-- Modify Ettore: 2016-11-17 - Aggiunto il campo PropostaTerapeutica
-- Description:	Restituisce le prescrizioni di un paziente ricercate in modo fuzzy
-- =============================================
CREATE PROCEDURE [ws3].[PrescrizioniByPazienteFuzzy]
(
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER
	, @Ordinamento		VARCHAR(128)
	, @ByPassaConsenso	BIT
	, @Cognome 			VARCHAR(64)=NULL
	, @Nome 			VARCHAR(64)=NULL
	, @DataNascita		DATETIME=NULL
	, @AnnoNascita		INT=NULL
	, @CodiceFiscale 	VARCHAR(16)=NULL
	, @CodiceSanitario	VARCHAR(12)=NULL
	, @Anagrafica 		VARCHAR(16)=NULL
	, @IdAnagrafica		VARCHAR(64)=NULL
	, @DallaData		DATETIME=NULL
	, @AllaData			DATETIME=NULL
) WITH RECOMPILE
AS
BEGIN
/*
	Restituisce le prescrizioni ricercate in modo fuzzy associate al paziente (all'intera catena di fusione) 
	Per ora viene passato @IdToken ma non viene utilizzato	
*/
	SET NOCOUNT ON
	DECLARE @PazientiFuzzy TABLE (Id uniqueidentifier NOT NULL  PRIMARY KEY, IdPazienteAttivo UNIQUEIDENTIFIER
								, DallaData DATETIME)
	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento ,'')
	--
	-- MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
	--
	IF @ByPassaConsenso = 1
	BEGIN
		IF NOT EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) WHERE Accesso = 'ATTRIB@ACCES_NEC_CLIN')
		BEGIN
			DECLARE @Errore NVARCHAR(4000);
			SET @Errore= N'[SecurityError]Il ruolo corrente non ha il permesso di bypassare il consenso.' 
			RAISERROR(@Errore, 16, 1)
			RETURN
		END
	END
	--
	-- Limitazione records restituiti da database
	--
	DECLARE @Top INTEGER  
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Prescrizioni') , 2000)	
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top
	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DallaDataPartizione DATETIME
	SELECT @DallaDataPartizione = dbo.OttieniFiltroPrescrizioniPerDataPartizione(@DallaData)

	-------------------------------------------------------------------------------------------------------------------------
	--  Ricerco i Pazienti per Anagrafica+Codice + Cognome+Nome+CF + Cognome+Nome+CS + Cognome+Nome+DN
	-------------------------------------------------------------------------------------------------------------------------

	INSERT INTO @PazientiFuzzy (Id, IdPazienteAttivo, DallaData)
		SELECT Id, COALESCE(FusioneId, ID)

			-- Calcolo la data in base al consenso
			, CASE WHEN @ByPassaConsenso = 1 THEN @Dalladata
				ELSE [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData) END

		FROM [sac].[OttienePazientiPerFuzzy](10000, @Cognome, @Nome, @DataNascita, @AnnoNascita
											, @CodiceFiscale, @CodiceSanitario, @Anagrafica, @IdAnagrafica)
	--
	-- Restituisco i dati
	--
	SELECT TOP (@MaxNumRow)
		P.Id
		, P.Cognome
		, P.Nome
		, P.CodiceFiscale
		, P.DataNascita
		, P.ComuneNascita
		, P.Sesso      
		, P.CodiceSanitario
		, P.StatoCodice
		, P.TipoPrescrizione
		, P.DataPrescrizione
		, P.NumeroPrescrizione
		, P.QuesitoDiagnostico		
		, P.MedicoPrescrittoreCodiceFiscale
		, P.MedicoPrescrittoreCognome
		, P.MedicoPrescrittoreNome
		, P.PrioritaCodice		
		, P.EsenzioneCodici
		, P.Prestazioni
		, P.Farmaci		
		, P.PropostaTerapeutica
	FROM 
		ws3.Prescrizioni AS P
		INNER JOIN @PazientiFuzzy PF
			ON P.IdPaziente = PF.id
	WHERE	
		--
		-- Filtro per DataPrescrizione (DINAMICO SUL CONSENSO)
		--
			(P.DataPrescrizione>= PF.DallaData OR PF.DallaData IS NULL) 
		AND (P.DataPrescrizione <= @AllaData OR @AllaData IS NULL)
		--
		-- Filtro per DataPartizione (STATICO)
		--
		AND (P.DataPartizione >= @DallaDataPartizione OR @DallaDataPartizione IS NULL) 
	ORDER BY 
		--Default
		CASE @Ordinamento  WHEN '' THEN P.DataPrescrizione END DESC --ordinamento di default
		--Ascendente
		, CASE @Ordinamento  WHEN 'Id@ASC' THEN P.Id END
        , CASE @Ordinamento  WHEN 'Cognome@ASC' THEN P.Cognome END
        , CASE @Ordinamento  WHEN 'Nome@ASC' THEN P.Nome END
        , CASE @Ordinamento  WHEN 'CodiceFiscale@ASC' THEN P.CodiceFiscale END
        , CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN P.DataNascita END
        , CASE @Ordinamento  WHEN 'ComuneNascita@ASC' THEN P.ComuneNascita END
        , CASE @Ordinamento  WHEN 'Sesso@ASC' THEN P.Sesso END
        , CASE @Ordinamento  WHEN 'CodiceSanitario@ASC' THEN P.CodiceSanitario END
        , CASE @Ordinamento  WHEN 'StatoCodice@ASC' THEN P.StatoCodice END
        , CASE @Ordinamento  WHEN 'TipoPrescrizione@ASC' THEN P.TipoPrescrizione END            
        , CASE @Ordinamento  WHEN 'DataPrescrizione@ASC' THEN P.DataPrescrizione END            
        , CASE @Ordinamento  WHEN 'NumeroPrescrizione@ASC' THEN P.NumeroPrescrizione END            
        , CASE @Ordinamento  WHEN 'QuesitoDiagnostico@ASC' THEN P.QuesitoDiagnostico END            
        , CASE @Ordinamento  WHEN 'MedicoPrescrittoreCodiceFiscale@ASC' THEN P.MedicoPrescrittoreCodiceFiscale END            
        , CASE @Ordinamento  WHEN 'MedicoPrescrittoreCognome@ASC' THEN P.MedicoPrescrittoreCognome END
        , CASE @Ordinamento  WHEN 'MedicoPrescrittoreNome@ASC' THEN P.MedicoPrescrittoreNome END            
        , CASE @Ordinamento  WHEN 'PrioritaCodice@ASC' THEN P.PrioritaCodice END                        
        , CASE @Ordinamento  WHEN 'EsenzioneCodici@ASC' THEN P.EsenzioneCodici END                                    
        , CASE @Ordinamento  WHEN 'Prestazioni@ASC' THEN P.Prestazioni END                                    
        , CASE @Ordinamento  WHEN 'Farmaci@ASC' THEN P.Farmaci END                                            
		, CASE @Ordinamento  WHEN 'PropostaTerapeutica@ASC' THEN P.PropostaTerapeutica END 
        --Discendente
		, CASE @Ordinamento  WHEN 'Id@DESC' THEN P.Id END DESC
        , CASE @Ordinamento  WHEN 'Cognome@DESC' THEN P.Cognome END DESC
        , CASE @Ordinamento  WHEN 'Nome@DESC' THEN P.Nome END DESC
        , CASE @Ordinamento  WHEN 'CodiceFiscale@DESC' THEN P.CodiceFiscale END DESC
        , CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN P.DataNascita END DESC
        , CASE @Ordinamento  WHEN 'ComuneNascita@DESC' THEN P.ComuneNascita END DESC
        , CASE @Ordinamento  WHEN 'Sesso@DESC' THEN P.Sesso END DESC
        , CASE @Ordinamento  WHEN 'CodiceSanitario@DESC' THEN P.CodiceSanitario END DESC
        , CASE @Ordinamento  WHEN 'StatoCodice@DESC' THEN P.StatoCodice END DESC
        , CASE @Ordinamento  WHEN 'TipoPrescrizione@DESC' THEN P.TipoPrescrizione END DESC            
        , CASE @Ordinamento  WHEN 'DataPrescrizione@DESC' THEN P.DataPrescrizione END DESC            
        , CASE @Ordinamento  WHEN 'NumeroPrescrizione@DESC' THEN P.NumeroPrescrizione END DESC            
        , CASE @Ordinamento  WHEN 'QuesitoDiagnostico@DESC' THEN P.QuesitoDiagnostico END DESC            
        , CASE @Ordinamento  WHEN 'MedicoPrescrittoreCodiceFiscale@DESC' THEN P.MedicoPrescrittoreCodiceFiscale END DESC            
        , CASE @Ordinamento  WHEN 'MedicoPrescrittoreCognome@DESC' THEN P.MedicoPrescrittoreCognome END DESC
        , CASE @Ordinamento  WHEN 'MedicoPrescrittoreNome@DESC' THEN P.MedicoPrescrittoreNome END DESC            
        , CASE @Ordinamento  WHEN 'PrioritaCodice@DESC' THEN P.PrioritaCodice END DESC
        , CASE @Ordinamento  WHEN 'EsenzioneCodici@DESC' THEN P.EsenzioneCodici END DESC
        , CASE @Ordinamento  WHEN 'Prestazioni@DESC' THEN P.Prestazioni END DESC
        , CASE @Ordinamento  WHEN 'Farmaci@DESC' THEN P.Farmaci END DESC
		, CASE @Ordinamento  WHEN 'PropostaTerapeutica@DESC' THEN P.PropostaTerapeutica END DESC
END