









-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-27
-- Description:	Restituisce le note anamnestiche di un paziente per IdPaziente (attivo)
-- =============================================
CREATE PROCEDURE [ws3].[NoteAnamnesticheByPaziente]
(
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER
	, @Ordinamento		VARCHAR(128)
	, @ByPassaConsenso	BIT	
	, @IdPaziente		UNIQUEIDENTIFIER
	, @Dalladata		DATETIME=NULL
	, @AllaData			DATETIME=NULL
)
AS
BEGIN
/*
	Restituisce le note anamnestiche associate al paziente (all'intera catena di fusione) 
*/
	SET NOCOUNT ON
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
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroNoteAnamnestichePerDataPartizione(@DallaData)	
	--
	-- Trovo i dati del consenso aziendale del paziente solo se non è stato forzato il consenso
	--
	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@Dalladata = [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPaziente
	END
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
	SELECT Id FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)	
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
		INNER JOIN @TablePazienti Pazienti
			ON N.IdPaziente = Pazienti.Id
		WHERE	
			--
			-- Filtro per DataPrescrizione e DataPartizione
			--
			(N.DataNota >= @DallaData OR @DallaData IS NULL) AND (N.DataNota<= @AllaData OR @AllaData IS NULL)
			AND (N.DataPartizione >= @DataPartizioneDal OR @DataPartizioneDal IS NULL) 
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