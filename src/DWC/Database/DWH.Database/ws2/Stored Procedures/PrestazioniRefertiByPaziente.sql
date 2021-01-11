



CREATE PROCEDURE [ws2].[PrestazioniRefertiByPaziente]
(
	@IdPaziente as uniqueidentifier, 
	@DallaDataReferto as datetime, 
	@SistemaErogante as varchar(16) = NULL,
	@RepartoErogante as varchar(16) = NULL,
	@PrestazioneCodice as varchar(16) = NULL,
	@SezioneCodice as varchar(16) = NULL,
	@IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
BEGIN 
	SET NOCOUNT ON
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2PrestazioniRefertiByPaziente
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti

	Limitazione record restituiti
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto				

	Non si trasla nel paziente attivo.
	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
								La @DallaDataReferto è obbligatoria, eseguo comunque il test
*/	

	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Prestazioni') , 2000)
	--
	-- Ricavo eventualmente la data minima dalle configurazioni
	--
	IF @DallaDataReferto IS NULL
	BEGIN 
		SET @DallaDataReferto = DATEADD(day, - ISNULL([dbo].[GetConfigurazioneInt] ('Ws2','RefertiDaGiorni') , 3650), GETDATE())
	END 
	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaDataReferto)
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
			@DallaDataReferto = [dbo].[GetDataMinimaByConsensoAziendale](@DallaDataReferto, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPaziente
	END	
	
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
	SELECT  TOP (@Top)
			Referti.Id AS IdReferti,
			Referti.AziendaErogante,
			Referti.SistemaErogante,
			Referti.RepartoErogante,
			Referti.DataReferto,
			Referti.NumeroReferto,
			Referti.NumeroNosologico,
			Referti.NumeroPrenotazione,
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
			
			Prestazioni.Id AS IdPrestazioni,
			--modifica per problema referti EndoScopiaDigestiva senza DataEogazione
			ISNULL(Prestazioni.DataErogazione, Referti.DataReferto) AS DataErogazione,
			Prestazioni.SezionePosizione,
			Prestazioni.SezioneCodice,
			Prestazioni.SezioneDescrizione,
			Prestazioni.PrestazionePosizione,
			Prestazioni.PrestazioneCodice,
			Prestazioni.PrestazioneDescrizione,
			--Prestazioni.RunningNumber,
			CAST(NULL AS INT) AS RunningNumber, --lo restiuisco cosi per compatibilità, poiche la vista store.Prestazioni non lo restituisce
			Prestazioni.GravitaCodice,
			Prestazioni.GravitaDescrizione,
			Prestazioni.Risultato,
			Prestazioni.ValoriRiferimento,
			Prestazioni.Commenti,
			Referti.DataEvento,
			Referti.Firmato,
			Referti.Oscuramenti
	FROM	
			ws2.Referti AS Referti
			--
			-- Filtro per paziente
			--
			INNER JOIN @TablePazienti AS Pazienti
				ON Referti.IdPaziente = Pazienti.Id			
			--INNER JOIN dbo.PrestazioniWs AS Prestazioni ON Referti.ID = Prestazioni.IdRefertiBase				
			INNER JOIN store.Prestazioni AS Prestazioni ON Referti.ID = Prestazioni.IdRefertiBase
	WHERE	
			(Referti.DataReferto >= @DallaDataReferto) AND
			(Referti.SistemaErogante LIKE @SistemaErogante OR NULLIF(@SistemaErogante, '') IS NULL) AND
			(Referti.RepartoErogante LIKE @RepartoErogante OR NULLIF(@RepartoErogante, '') IS NULL) AND 
			(Prestazioni.PrestazioneCodice LIKE @PrestazioneCodice OR NULLIF(@PrestazioneCodice, '') IS NULL) AND
			(Prestazioni.SezioneCodice LIKE @SezioneCodice OR NULLIF(@SezioneCodice, '') IS NULL) 
			--
			-- Filtro per DataPartizione
			--
			AND (Referti.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)

	ORDER BY Referti.DataReferto Desc, Referti.NumeroReferto Desc, Prestazioni.DataErogazione Desc;
		
END

