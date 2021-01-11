

CREATE PROCEDURE [ws3].[PrestazioniRefertiByPaziente]
(
	@IdToken			UNIQUEIDENTIFIER 
	, @MaxNumRow		INTEGER
	, @Ordinamento		VARCHAR(128)
	, @ByPassaConsenso	BIT
	, @IdPaziente		UNIQUEIDENTIFIER 
	, @DallaData DATETIME 
	, @AllaData  DATETIME 
	, @SistemaErogante	VARCHAR(16) = NULL
	, @RepartoErogante	VARCHAR(64) = NULL	--descrizione del reparto erogante - non esiste il codice del reparto erogante nei referti
	, @PrestazioneCodice VARCHAR(16) = NULL --anche se in store.Prestazioni è un VARCHAR(12)
	, @SezioneCodice	VARCHAR(16) = NULL	--anche se in store.Prestazioni è un VARCHAR(12)
)
AS
BEGIN 
	SET NOCOUNT ON
/*
	CREATA DA ETTORE 2016-03-25:
		Differenze dalla versione ws2: non viene restituito il campo RunnigNumber
		Traslazione dell'@IdPaziente nel paziente attivo
		Aggiunto il parametro @AllaData
		Ho dovuto cambiare la forma del filtro per Sistemi
		Si filtra su Referti.DataEvento

	MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
*/	
	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento ,'')
	--
	-- Verifico se al token è associato l'attibuto ATTRIB@VIEW_ALL
	--
	DECLARE @ViewAll as BIT=0
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
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
	-- Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	--
	-- Limitazione records restituiti da database
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Prestazioni') , 2000)
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top
	--
	-- @AllaData
	--
	IF @AllaData IS NULL 
		SET @AllaData = GETDATE()
	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaData)
	--
	-- Trovo i dati del consenso aziendale del paziente solo se non è stato forzato il consenso
	--
	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@DallaData = [dbo].[GetDataMinimaByConsensoAziendale](@DallaData, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPaziente
	END	
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	--
	--
	--	
	SELECT  TOP (@MaxNumRow)
			--
			-- Parte Referti
			--
			Referti.Id AS IdReferti,
			Referti.DataInserimento,
			Referti.DataModifica,
			Referti.AziendaErogante,
			Referti.SistemaErogante,
			Referti.RepartoErogante,
			Referti.DataReferto,
			Referti.DataEvento,
			Referti.NumeroReferto,
			Referti.NumeroNosologico,
			Referti.NumeroPrenotazione,
			Referti.IdOrderEntry,
			Referti.Cognome,
			Referti.Nome,
			Referti.CodiceFiscale,
			Referti.DataNascita,
			Referti.ComuneNascita,
			Referti.RepartoRichiedenteCodice,
			Referti.RepartoRichiedenteDescr,
			Referti.StatoRichiestaCodice,
			Referti.StatoRichiestaDescr,
			Referti.TipoRichiestaCodice,
			Referti.TipoRichiestaDescr,
			Referti.Firmato,
			--
			-- Parte Prestazioni			
			--
			Prestazioni.Id AS IdPrestazioni,
			--Modifica per problema referti EndoScopiaDigestiva senza DataErogazione
			ISNULL(Prestazioni.DataErogazione, Referti.DataReferto) AS DataErogazione,
			Prestazioni.SezionePosizione,
			Prestazioni.SezioneCodice,
			Prestazioni.SezioneDescrizione,
			Prestazioni.PrestazionePosizione,
			Prestazioni.PrestazioneCodice,
			Prestazioni.PrestazioneDescrizione,
			Prestazioni.GravitaCodice,
			Prestazioni.GravitaDescrizione,
			
			Prestazioni.Risultato,
			Prestazioni.Quantita,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( Prestazioni.Id, Prestazioni.DataPartizione, 'UnitaDiMisuraDescrizione')) as UnitaDiMisuraDescrizione,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( Prestazioni.Id, Prestazioni.DataPartizione, 'UnitaDiMisuraSistema')) as UnitaDiMisuraSistema,
			Prestazioni.ValoriRiferimento,						
			Prestazioni.RangeValoreMinimo AS RangeDiNormalitaValoreMinimo,
			Prestazioni.RangeValoreMinimoUnitaDiMisura AS RangeDiNormalitaValoreMinimoUDM,
			Prestazioni.RangeValoreMassimo AS RangeDiNormalitaValoreMassimo,
			Prestazioni.RangeValoreMassimoUnitaDiMisura AS RangeDiNormalitaValoreMassimoUDM,			
			Prestazioni.Commenti
	FROM	
			ws3.Referti AS Referti
			--
			-- Filtro per paziente
			--
			INNER JOIN @TablePazienti AS Pazienti
				ON Referti.IdPaziente = Pazienti.Id			
			INNER JOIN store.Prestazioni AS Prestazioni 
				ON Referti.ID = Prestazioni.IdRefertiBase
			LEFT OUTER JOIN [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
				ON SE.AziendaErogante = Referti.AziendaErogante AND SE.SistemaErogante = Referti.SistemaErogante
	WHERE	
		--Scritto cosi è lento
		--(
		--	(@ViewAll = 1) 
		--	OR 
		--	EXISTS( SELECT * FROM [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
		--			WHERE   Referti.SistemaErogante = SE.SistemaErogante AND Referti.AziendaErogante = SE.AziendaErogante)
		--) AND
		--
		-- Filtro per Sistema e Oscuramenti
		--
		(
			(@ViewAll = 1) 
			OR 
			(
				(Referti.SistemaErogante = SE.SistemaErogante AND  Referti.AziendaErogante = SE.AziendaErogante)
				AND 
				([dbo].[CheckRefertoOscuramenti] (@IdRuolo, Referti.Id, Referti.DataPartizione, Referti.AziendaErogante, Referti.SistemaErogante
												, Referti.StrutturaEroganteCodice, Referti.NumeroNosologico, Referti.RepartoRichiedenteCodice
												, Referti.RepartoErogante, Referti.Confidenziale ) = 1)
			)
		) AND
		(Referti.DataEvento between @DallaData AND @AllaData) AND
		(Referti.SistemaErogante LIKE @SistemaErogante OR NULLIF(@SistemaErogante, '') IS NULL) AND
		(Referti.RepartoErogante LIKE @RepartoErogante OR NULLIF(@RepartoErogante, '') IS NULL) AND 
		(Prestazioni.PrestazioneCodice LIKE @PrestazioneCodice OR NULLIF(@PrestazioneCodice, '') IS NULL) AND
		(Prestazioni.SezioneCodice LIKE @SezioneCodice OR NULLIF(@SezioneCodice, '') IS NULL) 
		--
		-- Filtro per DataPartizione
		--
		AND (Referti.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
	ORDER BY 
	--Default
	CASE @Ordinamento  WHEN '' THEN Referti.DataEvento END DESC
	, CASE @Ordinamento  WHEN '' THEN Referti.NumeroReferto END DESC
	, CASE @Ordinamento  WHEN '' THEN Prestazioni.DataErogazione END DESC
	--Ascendente	
	, CASE @Ordinamento  WHEN 'Referti@ASC' THEN Referti.Id END ASC
	, CASE @Ordinamento  WHEN 'DataInserimento@ASC' THEN Referti.DataInserimento END ASC
	, CASE @Ordinamento  WHEN 'DataModifica@ASC' THEN Referti.DataModifica END ASC
	, CASE @Ordinamento  WHEN 'AziendaErogante@ASC' THEN Referti.AziendaErogante END ASC
	, CASE @Ordinamento  WHEN 'SistemaErogante@ASC' THEN Referti.SistemaErogante END ASC
	, CASE @Ordinamento  WHEN 'RepartoErogante@ASC' THEN Referti.RepartoErogante END ASC
	, CASE @Ordinamento  WHEN 'DataReferto@ASC' THEN Referti.DataReferto END ASC
	, CASE @Ordinamento  WHEN 'DataEvento@ASC' THEN Referti.DataEvento END ASC
	, CASE @Ordinamento  WHEN 'NumeroReferto@ASC' THEN Referti.NumeroReferto END ASC
	, CASE @Ordinamento  WHEN 'NumeroNosologico@ASC' THEN Referti.NumeroNosologico END ASC
	, CASE @Ordinamento  WHEN 'NumeroPrenotazione@ASC' THEN Referti.NumeroPrenotazione END ASC
	, CASE @Ordinamento  WHEN 'IdOrderEntry@ASC' THEN Referti.IdOrderEntry END ASC
	, CASE @Ordinamento  WHEN 'Cognome@ASC' THEN Referti.Cognome END ASC
	, CASE @Ordinamento  WHEN 'Nome@ASC' THEN Referti.Nome END ASC
	, CASE @Ordinamento  WHEN 'CodiceFiscale@ASC' THEN Referti.CodiceFiscale END ASC
	, CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN Referti.DataNascita END ASC
	, CASE @Ordinamento  WHEN 'ComuneNascita@ASC' THEN Referti.ComuneNascita END ASC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteCodice@ASC' THEN Referti.RepartoRichiedenteCodice END ASC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteDescr@ASC' THEN Referti.RepartoRichiedenteDescr END ASC
	, CASE @Ordinamento  WHEN 'StatoRichiestaCodice@ASC' THEN Referti.StatoRichiestaCodice END ASC
	, CASE @Ordinamento  WHEN 'StatoRichiestaDescr@ASC' THEN Referti.StatoRichiestaDescr END ASC
	, CASE @Ordinamento  WHEN 'TipoRichiestaCodice@ASC' THEN Referti.TipoRichiestaCodice END ASC
	, CASE @Ordinamento  WHEN 'TipoRichiestaDescr@ASC' THEN Referti.TipoRichiestaDescr END ASC
	, CASE @Ordinamento  WHEN 'Firmato@ASC' THEN Referti.Firmato END ASC
	, CASE @Ordinamento  WHEN 'IdPrestazioni@ASC' THEN Prestazioni.Id END ASC 
	, CASE @Ordinamento  WHEN 'DataErogazione@ASC' THEN ISNULL(Prestazioni.DataErogazione, Referti.DataReferto) END ASC 
	, CASE @Ordinamento  WHEN 'SezionePosizione@ASC' THEN Prestazioni.SezionePosizione END ASC 
	, CASE @Ordinamento  WHEN 'SezioneCodice@ASC' THEN Prestazioni.SezioneCodice END ASC 
	, CASE @Ordinamento  WHEN 'SezioneDescrizione@ASC' THEN Prestazioni.SezioneDescrizione END ASC 
	, CASE @Ordinamento  WHEN 'PrestazionePosizione@ASC' THEN Prestazioni.PrestazionePosizione END ASC 
	, CASE @Ordinamento  WHEN 'PrestazioneCodice@ASC' THEN Prestazioni.PrestazioneCodice END ASC 
	, CASE @Ordinamento  WHEN 'PrestazioneDescrizione@ASC' THEN Prestazioni.PrestazioneDescrizione END ASC 
	, CASE @Ordinamento  WHEN 'GravitaCodice@ASC' THEN Prestazioni.GravitaCodice END ASC 
	, CASE @Ordinamento  WHEN 'GravitaDescrizione@ASC' THEN Prestazioni.GravitaDescrizione END ASC 
	, CASE @Ordinamento  WHEN 'Risultato@ASC' THEN Prestazioni.Risultato END ASC 
	, CASE @Ordinamento  WHEN 'ValoriRiferimento@ASC' THEN Prestazioni.ValoriRiferimento END ASC 
	, CASE @Ordinamento  WHEN 'Commenti@ASC' THEN Prestazioni.Commenti END ASC 
    --Discendente	
	, CASE @Ordinamento  WHEN 'Referti@DESC' THEN Referti.Id END DESC
	, CASE @Ordinamento  WHEN 'DataInserimento@DESC' THEN Referti.DataInserimento END DESC
	, CASE @Ordinamento  WHEN 'DataModifica@DESC' THEN Referti.DataModifica END DESC
	, CASE @Ordinamento  WHEN 'AziendaErogante@DESC' THEN Referti.AziendaErogante END DESC
	, CASE @Ordinamento  WHEN 'SistemaErogante@DESC' THEN Referti.SistemaErogante END DESC
	, CASE @Ordinamento  WHEN 'RepartoErogante@DESC' THEN Referti.RepartoErogante END DESC
	, CASE @Ordinamento  WHEN 'DataReferto@DESC' THEN Referti.DataReferto END DESC
	, CASE @Ordinamento  WHEN 'DataEvento@DESC' THEN Referti.DataEvento END DESC
	, CASE @Ordinamento  WHEN 'NumeroReferto@DESC' THEN Referti.NumeroReferto END DESC
	, CASE @Ordinamento  WHEN 'NumeroNosologico@DESC' THEN Referti.NumeroNosologico END DESC
	, CASE @Ordinamento  WHEN 'NumeroPrenotazione@DESC' THEN Referti.NumeroPrenotazione END DESC
	, CASE @Ordinamento  WHEN 'IdOrderEntry@DESC' THEN Referti.IdOrderEntry END DESC
	, CASE @Ordinamento  WHEN 'Cognome@DESC' THEN Referti.Cognome END DESC
	, CASE @Ordinamento  WHEN 'Nome@DESC' THEN Referti.Nome END DESC
	, CASE @Ordinamento  WHEN 'CodiceFiscale@DESC' THEN Referti.CodiceFiscale END DESC
	, CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN Referti.DataNascita END DESC
	, CASE @Ordinamento  WHEN 'ComuneNascita@DESC' THEN Referti.ComuneNascita END DESC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteCodice@DESC' THEN Referti.RepartoRichiedenteCodice END DESC
	, CASE @Ordinamento  WHEN 'RepartoRichiedenteDescr@DESC' THEN Referti.RepartoRichiedenteDescr END DESC
	, CASE @Ordinamento  WHEN 'StatoRichiestaCodice@DESC' THEN Referti.StatoRichiestaCodice END DESC
	, CASE @Ordinamento  WHEN 'StatoRichiestaDescr@DESC' THEN Referti.StatoRichiestaDescr END DESC
	, CASE @Ordinamento  WHEN 'TipoRichiestaCodice@DESC' THEN Referti.TipoRichiestaCodice END DESC
	, CASE @Ordinamento  WHEN 'TipoRichiestaDescr@DESC' THEN Referti.TipoRichiestaDescr END DESC
	, CASE @Ordinamento  WHEN 'Firmato@DESC' THEN Referti.Firmato END DESC
	, CASE @Ordinamento  WHEN 'IdPrestazioni@DESC' THEN Prestazioni.Id END DESC 
	, CASE @Ordinamento  WHEN 'DataErogazione@DESC' THEN ISNULL(Prestazioni.DataErogazione, Referti.DataReferto) END DESC 
	, CASE @Ordinamento  WHEN 'SezionePosizione@DESC' THEN Prestazioni.SezionePosizione END DESC 
	, CASE @Ordinamento  WHEN 'SezioneCodice@DESC' THEN Prestazioni.SezioneCodice END DESC 
	, CASE @Ordinamento  WHEN 'SezioneDescrizione@DESC' THEN Prestazioni.SezioneDescrizione END DESC 
	, CASE @Ordinamento  WHEN 'PrestazionePosizione@DESC' THEN Prestazioni.PrestazionePosizione END DESC 
	, CASE @Ordinamento  WHEN 'PrestazioneCodice@DESC' THEN Prestazioni.PrestazioneCodice END DESC 
	, CASE @Ordinamento  WHEN 'PrestazioneDescrizione@DESC' THEN Prestazioni.PrestazioneDescrizione END DESC 
	, CASE @Ordinamento  WHEN 'GravitaCodice@DESC' THEN Prestazioni.GravitaCodice END DESC 
	, CASE @Ordinamento  WHEN 'GravitaDescrizione@DESC' THEN Prestazioni.GravitaDescrizione END DESC 
	, CASE @Ordinamento  WHEN 'Risultato@DESC' THEN Prestazioni.Risultato END DESC 
	, CASE @Ordinamento  WHEN 'ValoriRiferimento@DESC' THEN Prestazioni.ValoriRiferimento END DESC 
	, CASE @Ordinamento  WHEN 'Commenti@DESC' THEN Prestazioni.Commenti END DESC 
    
END