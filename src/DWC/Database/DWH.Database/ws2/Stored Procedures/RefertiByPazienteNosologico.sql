





-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Restituisce la lista dei referti relativi ad un Numero nosologico e per un intervallo di date
-- Modify date: 2015-07-24 - ETTORE: traslazione dell’IdPaziente passato come parametro nell’IdPaziente Attivo
-- Modify date: 2017-10-09 - ETTORE: Gestione filtro basato sul consenso 
-- Modify date: 2019-01-16 - ETTORE: Eliminato l'uso delle costanti ASMN e AUSL usate per invocare la funzione dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero()
--									 Limitazione [@DallaData, @AllaData] in base ai nosologici della prenotazione e del ricovero
-- =============================================
CREATE PROCEDURE ws2.RefertiByPazienteNosologico
	@IdPaziente UNIQUEIDENTIFIER,		--obbligatorio
	@NumeroNosologico varchar(64),		--obbligatorio
	@AziendaErogante varchar(16)=NULL,	--facoltativo  --AziendaErogante del referto
	@DallaData datetime = NULL,			--facoltativo
	@AllaData datetime = NULL,			--facoltativo
	@IdRuolo	uniqueidentifier=NULL
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertiByPazienteNosologico
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
	Restituisce la lista dei referti relativi ad un Numero nosologico e per un intervallo di date
	
	Limitazione record restituiti
	Restituisco i referti associati sia al ricovero che alla prenotazione se @Nosologico è un codice ricovero
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto				
	Uso nuova funzione dbo.IsNosologicoListaDiAttesa() per capire se il numero nosologico è di una lista di attesa
	
*/
	SET NOCOUNT ON
	--
	-- Se @AziendaErogante è vuoto lo imposto a NULL
	--
	IF ISNULL(@AziendaErogante, '') = ''
		SET @AziendaErogante = NULL

	--
	-- Limitazione record restituiti
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)
	--
	-- Memorizzo il parametro @NumeroNosologico nella tabella
	--
	DECLARE @TabNosologici AS TABLE(CodiceNosologico VARCHAR(64))
	INSERT INTO @TabNosologici(CodiceNosologico) VALUES (@NumeroNosologico)
	--
	-- Cerco eventuali nosologici di lista di attesa e li aggiungo alla @TabNosologici 
	--
	IF dbo.IsNosologicoListaDiAttesa(@NumeroNosologico) = 0 
	BEGIN
		INSERT INTO @TabNosologici(CodiceNosologico)
		SELECT dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero(NULL, @NumeroNosologico) 
		--dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero restituisce NULL se non trova: cancello i NULL
		DELETE FROM @TabNosologici WHERE CodiceNosologico IS NULL
	END

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
	-- Ho già l'Id SAC: ricavo valori per DallaData e AllaData (associati alla prenotazione o al ricovero) dalla vista ws2.Ricoveri 
	-- Al massimo ci sono 2/3 record: eseguo un DISTINCT
	--
	DECLARE @TabIntervalloDate AS TABLE(DallaData DATETIME, AllaData DATETIME)
	INSERT INTO @TabIntervalloDate(DallaData, AllaData)
	SELECT DISTINCT
		-- Stiamo un po larghi come finestra temporale
		DATEADD(month, - 1, DataAccettazione) AS DallaData
		-- Le colture di microbiologia possono durare mesi, magari il referto arriva dopo la dimissione
		, DATEADD(month, + 12, DataDimissione) AS AllaData
	FROM ws2.Ricoveri
	WHERE NumeroNosologico IN (SELECT CodiceNosologico FROM @TabNosologici)

	--
	-- Trovo la minima data e la massima data relativa ai nosologici
	--
	DECLARE @DallaDataMin DATETIME  
	DECLARE @AllaDataMax DATETIME  
	SELECT @DallaDataMin = MIN(DallaData) FROM @TabIntervalloDate
	SELECT @AllaDataMax = MAX(AllaData) FROM @TabIntervalloDate WHERE NOT AllaData IS NULL
	--
	-- Limito la @DallaData e @AllaData in base alle date minime e massime ricavate sui nosologici
	--
	IF @DallaData IS NULL SET @DallaData = @DallaDataMin 
	ELSE
		IF @DallaData < @DallaDataMin SET @DallaData = @DallaDataMin 
		
	IF @AllaData IS NULL  SET @AllaData = @AllaDataMax
	ELSE
		IF @AllaData > @AllaDataMax SET @AllaData = @AllaDataMax

	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaData)
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)

	--
	-- Se non posso bypassare il consenso applico il filtro in base al consenso associato al paziente
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
	DECLARE @TableAllIdPazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TableAllIdPazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)


	--
	--
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
		CAST(R.SpecialitaErogante AS VARCHAR(128)) AS SpecialitaErogante,
		R.DataEvento,
		R.Firmato,
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		R.Oscuramenti
	FROM	
		ws2.Referti AS R
		--
		-- Filtro per paziente
		--
		INNER JOIN @TableAllIdPazienti P
			ON R.IdPaziente = P.Id		
	WHERE	
		(
			R.NumeroNosologico  IN (SELECT CodiceNosologico FROM  @TabNosologici)
		)
		AND (R.AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		--
		-- Filtro per @DallaData 
		--
		AND (R.DataReferto >= @DallaData OR @DallaData IS NULL)
		AND (R.DataReferto <= @AllaData OR @AllaData IS NULL)
		--
		-- Filtro per DataPartizione
		--
		AND (R.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
	ORDER BY R.DataReferto DESC

	RETURN @@ERROR
END



