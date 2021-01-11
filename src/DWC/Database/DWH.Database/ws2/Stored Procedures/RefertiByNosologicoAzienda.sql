-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Restituisce la lista dei referti associati al nosologico e alla sua eventuale prenotazione
-- Modify date: 2017-10-10 - ETTORE: Gestione filtro basato sul consenso 
-- Modify date: 2018-01-08 - ETTORE: Modificato il range temporale di ricerca dei referti (DataDal = DataDimissione + 12 mesi)
--										(Prima DataDal = DataDimissione + 6 mesi)
-- Modify date: 2019-01-10 - ETTORE: Il parametro @AziendaErogante NON è più obbligatorio
-- =============================================
CREATE PROCEDURE ws2.RefertiByNosologicoAzienda
(
	@NumeroNosologico varchar(64),
	@AziendaErogante as varchar(16),	--Azienda che eroga il nosologico
	@IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
BEGIN
/*
	Sostituisce la dbo.Ws2RefertiByNosologicoAzienda
	Restituito il campo XML Oscuramenti
	Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista
	
	Affinchè questa SP restituisce dei referti
	bisogna che il nosologico esista negli Eventi di Ricovero (ADT) e nella tabella Ricoveri

	Traslo l'idpaziente nell'idpaziente attivo			
	Limitazione record restituiti + ORDER BY DataReferto DESC
	Restituisco i referti associati sia al ricovero che alla prenotazione se @Nosologico è un codice ricovero
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto				
	Uso nuova funzione dbo.IsNosologicoListaDiAttesa() per capire se il numero nosologico è di una lista di attesa
*/	

	SET NOCOUNT ON
	DECLARE @DallaData DATETIME
	DECLARE @Alladata DATETIME
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
	-- Ricavo gli IdSac del/dei pazienti e i valori per DallaData e AllaData (associati alla prenotazione o al ricovero) dalla vista ws2.Ricoveri 
	-- Al massimo ci sono 2/3 record: eseguo un DISTINCT
	--
	DECLARE @TabPazienti_Date AS TABLE(IdPaziente UNIQUEIDENTIFIER, DallaData DATETIME, AllaData DATETIME)
	INSERT INTO @TabPazienti_Date(IdPaziente, DallaData, AllaData )
	SELECT DISTINCT
		IdPaziente
		-- Stiamo un po larghi come finestra temporale
		, DATEADD(month, - 1, DataAccettazione) AS DallaData
		-- Le colture di microbiologia possono durare mesi, magari il referto arriva dopo la dimissione
		, DATEADD(month, + 12, DataDimissione) AS AllaData
	FROM ws2.Ricoveri
	WHERE (AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
			AND NumeroNosologico IN (SELECT CodiceNosologico FROM @TabNosologici)
	--
	-- Memorizzo valori minimi e massimi (se c'è una lista di attesa questa è precedente al ricovero)
	--
	SELECT @DallaData = MIN(DallaData) FROM @TabPazienti_Date
	SELECT @AllaData = MAX(AllaData) FROM @TabPazienti_Date WHERE NOT AllaData IS NULL

	--
	-- Determino il paziente attivo a partire da un paziente  della tabella @TabPazienti_Date (devono appartenere alla stessa catena di fusione)
	--
	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER 
	SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM @TabPazienti_Date
	SELECT @IdPazienteAttivo = dbo.GetPazienteAttivoByIdSac(@IdPazienteAttivo)

	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DallaDataPartizione DATETIME
	SELECT @DallaDataPartizione = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaData)
	--
	-- In base a @BypassaConsenso calcolo una limitazione della DataDal
	--
	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@Dalladata = [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPazienteAttivo
	END	
	
	--
	-- Lista dei fusi + l'attivo per ogni IdPaziente
	-- 
	DECLARE @TableAllIdPazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TableAllIdPazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo)

	--
	-- Restituisco i dati
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
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		R.Oscuramenti
	FROM	
		ws2.Referti AS R
		--
		-- Filtro per paziente
		--
		INNER JOIN @TableAllIdPazienti AS P
			ON R.IdPaziente = P.Id
	
	WHERE	
		--voglio solo questo Nosologico a prescindere dall'Azienda
		--quindi più referti con stesso nosologico e diverse aziende
		R.NumeroNosologico IN (SELECT CodiceNosologico FROM @TabNosologici)
		--AND (AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		-- Se l'AziendaErogante NON è valorizzata non viene trovato l'IdPaziente
		-- e quindi non viene restituito nulla
		--
		-- Filtro in base alla finetra temporale [@DallaData,@AllaData] e alla finestra sulla data di partizione @DallaDataPartizione
		--
		AND (R.DataReferto >= @DallaData OR @DallaData IS NULL) 
		AND (R.DataReferto <= @AllaData OR @AllaData IS NULL) 
		AND (R.DataPartizione >= @DallaDataPartizione) 

	ORDER BY R.DataReferto DESC
			
	RETURN @@ERROR
END



