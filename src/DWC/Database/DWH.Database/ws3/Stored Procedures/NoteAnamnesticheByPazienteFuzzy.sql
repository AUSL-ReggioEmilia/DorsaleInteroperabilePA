









-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-27
-- Description:	Restituisce le note anamnestiche di un paziente ricercate in modo fuzzy
-- =============================================
CREATE PROCEDURE [ws3].[NoteAnamnesticheByPazienteFuzzy]
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
	Restituisce le anamnestiche ricercate in modo fuzzy associate al paziente (all'intera catena di fusione) 
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
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','NoteAnamnestiche') , 2000)	
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
		N.Id
		, N.IdPaziente
		, N.Cognome
		, N.Nome
		, N.CodiceFiscale
		, N.DataNascita
		, N.ComuneNascita
		, N.Sesso
		, N.CodiceSanitario
		, N.StatoCodice
		, N.StatoDescrizione
		, N.AziendaErogante
		, N.SistemaErogante
		, N.TipoCodice
		, N.TipoDescrizione
		, N.DataNota
		, N.DataFineValidita
		, N.ContenutoText
	FROM 
		ws3.NoteAnamnestiche AS N
		--
		-- Filtro per paziente
		--
		INNER JOIN @PazientiFuzzy PF
			ON N.IdPaziente = PF.id
		WHERE	
			--
			-- Filtro per DataPrescrizione e DataPartizione
			--
			(N.DataNota >= @DallaData OR @DallaData IS NULL) AND (N.DataNota<= @AllaData OR @AllaData IS NULL)
			AND (N.DataPartizione >= @DallaDataPartizione OR @DallaDataPartizione IS NULL) 
		ORDER BY 
				--Default
				CASE @Ordinamento  WHEN '' THEN N.DataNota END DESC --ordinamento di default
				--Ascendente
				, CASE @Ordinamento  WHEN 'Id@ASC' THEN N.Id END
				, CASE @Ordinamento  WHEN 'Cognome@ASC' THEN N.Cognome END
				, CASE @Ordinamento  WHEN 'Nome@ASC' THEN N.Nome END
				, CASE @Ordinamento  WHEN 'CodiceFiscale@ASC' THEN N.CodiceFiscale END
				, CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN N.DataNascita END
				, CASE @Ordinamento  WHEN 'ComuneNascita@ASC' THEN N.ComuneNascita END
				, CASE @Ordinamento  WHEN 'Sesso@ASC' THEN N.Sesso END
				, CASE @Ordinamento  WHEN 'CodiceSanitario@ASC' THEN N.CodiceSanitario END
				, CASE @Ordinamento  WHEN 'StatoCodice@ASC' THEN N.StatoCodice END
				, CASE @Ordinamento  WHEN 'StatoDescrizione@ASC' THEN N.StatoDescrizione END
				, CASE @Ordinamento  WHEN 'AziendaErogante@ASC' THEN N.AziendaErogante END            
				, CASE @Ordinamento  WHEN 'SistemaErogante@ASC' THEN N.SistemaErogante END            
				, CASE @Ordinamento  WHEN 'TipoCodice@ASC' THEN N.TipoCodice END            
				, CASE @Ordinamento  WHEN 'TipoDescrizione@ASC' THEN N.TipoDescrizione END            
				, CASE @Ordinamento  WHEN 'DataNota@ASC' THEN N.DataNota END
				, CASE @Ordinamento  WHEN 'DataFineValidita@ASC' THEN N.DataFineValidita END
				--Discendente
				, CASE @Ordinamento  WHEN 'Id@DESC' THEN N.Id END DESC
				, CASE @Ordinamento  WHEN 'Cognome@DESC' THEN N.Cognome END DESC
				, CASE @Ordinamento  WHEN 'Nome@DESC' THEN N.Nome END DESC
				, CASE @Ordinamento  WHEN 'CodiceFiscale@DESC' THEN N.CodiceFiscale END DESC
				, CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN N.DataNascita END DESC
				, CASE @Ordinamento  WHEN 'ComuneNascita@DESC' THEN N.ComuneNascita END DESC
				, CASE @Ordinamento  WHEN 'Sesso@DESC' THEN N.Sesso END DESC
				, CASE @Ordinamento  WHEN 'CodiceSanitario@DESC' THEN N.CodiceSanitario END DESC
				, CASE @Ordinamento  WHEN 'StatoCodice@DESC' THEN N.StatoCodice END DESC
				, CASE @Ordinamento  WHEN 'StatoDescrizione@DESC' THEN N.StatoDescrizione END DESC
				, CASE @Ordinamento  WHEN 'AziendaErogante@DESC' THEN N.AziendaErogante END DESC
				, CASE @Ordinamento  WHEN 'SistemaErogante@DESC' THEN N.SistemaErogante END DESC       
				, CASE @Ordinamento  WHEN 'TipoCodice@DESC' THEN N.TipoCodice END DESC
				, CASE @Ordinamento  WHEN 'TipoDescrizione@DESC' THEN N.TipoDescrizione END DESC
				, CASE @Ordinamento  WHEN 'DataNota@DESC' THEN N.DataNota END DESC
				, CASE @Ordinamento  WHEN 'DataFineValidita@DESC' THEN N.DataFineValidita END DESC
	
END