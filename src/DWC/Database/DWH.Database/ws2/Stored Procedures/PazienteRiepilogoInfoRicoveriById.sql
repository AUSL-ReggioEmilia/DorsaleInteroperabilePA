

CREATE PROCEDURE [ws2].[PazienteRiepilogoInfoRicoveriById]
(
	@IdPaziente UNIQUEIDENTIFIER
	, @DatiRicoveroDaGiorni INT = NULL --serve a filtrare i ricoveri più vecchi di N giorni
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2PazienteRiepilogoInfoRicoveriById
		Aggiunto calcolo filtro per data partizione e filtro per data partizione - DA FINIRE	
		Uso la vista ws2.Ricoveri, basta onorare solo gli oscuramenti puntuali (FORACCHIA)
		ATTENZIONE: ho forzato l'uso della vista dbo.Ricoveri al posto della ws2.Ricoveri
					per avere gli stessi risultati di prima. CHIARIRE!!!
		
	Restituisce info di ricovero del paziente
	
	MODIFICA ETTORE 2015-07-24: traslazione dell’IdPaziente passato come parametro nell’IdPaziente Attivo	
*/

	SET NOCOUNT ON;
	
	DECLARE @AziendaEroganteDelRicovero varchar(16); DECLARE @NumeroNosologico varchar(64);
	DECLARE @TipoRicoveroCodice VARCHAR(16); DECLARE @TipoRicoveroDescr VARCHAR(128);
	DECLARE @DataDimissione AS DATETIME; DECLARE @DataAccettazione AS DATETIME;
	DECLARE @Ricoverato AS BIT; DECLARE @RepartoAccettazioneCodice VARCHAR(16);
	DECLARE @RepartoAccettazioneDescr VARCHAR(128); DECLARE @RepartoCodice VARCHAR(16);
	DECLARE @RepartoDescr VARCHAR(128);	DECLARE @SettoreCodice VARCHAR(16)
	DECLARE @SettoreDescr VARCHAR(128);	DECLARE @LettoCodice VARCHAR(16)
	
	DECLARE @DataMinimaAccettazione DATETIME
	DECLARE @DataPartizioneDal DATETIME	
	
	BEGIN TRY
		SET @Ricoverato = 0
		SET @DataMinimaAccettazione = NULL
		IF NOT @DatiRicoveroDaGiorni IS NULL
		BEGIN
			SET @DataMinimaAccettazione = DATEADD(day, - @DatiRicoveroDaGiorni, GETDATE())
			SELECT @DataPartizioneDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DataMinimaAccettazione)
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
		-- Informazioni di ricovero (relative all'ultimo ricovero)
		--
		SELECT TOP 1
			@AziendaEroganteDelRicovero = AziendaErogante
			, @NumeroNosologico = NumeroNosologico	
			-- Il tipo di ricovero: ordinario, pronto soccorso....
			, @TipoRicoveroCodice = TipoRicoveroCodice 
			, @TipoRicoveroDescr = TipoRicoveroDescr 		
			--Dati di accettazione						
			, @DataAccettazione = DataAccettazione
			, @RepartoAccettazioneCodice = RepartoAccettazioneCodice
			, @RepartoAccettazioneDescr = RepartoAccettazioneDescr 
			--Reparto attuale se riscovarto altrimenti ultimo reparto prima della dimissione
			, @RepartoCodice = RepartoCodice
			, @RepartoDescr  = RepartoDescr 
			, @SettoreCodice = SettoreCodice
			, @SettoreDescr = SettoreDescr
			, @LettoCodice = @LettoCodice
			------------------------------
			, @DataDimissione = DataDimissione
		FROM 
			--Uso ws2.Ricoveri perchè basta onorare gli oscuramenti puntuali (FORACCHIA)
			ws2.Ricoveri WITH(NOLOCK)
			INNER JOIN @TablePazienti Pazienti
				ON Ricoveri.IdPaziente = Pazienti.Id		
		WHERE 
			(@DataMinimaAccettazione IS NULL OR DataAccettazione >= @DataMinimaAccettazione)
			--
			-- Filtro per DataPartizione
			--
			AND (DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
			
		ORDER BY DataAccettazione DESC --in questo modo prendo l'ultimo ricovero
		--
		-- Verifico se il paziente è ricoverato
		--
		IF NOT @NumeroNosologico IS NULL
		BEGIN
			--
			-- Se data di dimissione è null -> ricoverato
			-- Se data di dimissione > GETDATE() -> ricoverato
			-- Se data di dimissione <= GETDATE() -> dimesso
			--
			IF NOT @DataDimissione IS NULL  
			BEGIN
				IF @DataDimissione > GETDATE()
					SET @Ricoverato = 1
				ELSE
					SET @Ricoverato = 0
			END 
			ELSE
				SET @Ricoverato = 1			
		END

		--
		-- Restituisco SOLO se ho trovato un ricovero
		--
		IF NOT @NumeroNosologico IS NULL
			SELECT 
				-- Dati di ricovero
				@IdPaziente AS IdPaziente
				, @Ricoverato AS Ricoverato
				, @AziendaEroganteDelRicovero AS AziendaErogante
				, @NumeroNosologico AS NumeroNosologico -- nosologico del ricovero (se NULL il paziente non è MAI stato ricoverato)
				, @TipoRicoveroCodice AS TipoRicoveroCodice 
				, @TipoRicoveroDescr AS TipoRicoveroDescr 		
				, @DataAccettazione AS DataAccettazione -- Data inizio episodio
				, @RepartoAccettazioneCodice AS RepartoAccettazioneCodice
				, @RepartoAccettazioneDescr AS RepartoAccettazioneDescr 
				, @RepartoCodice AS RepartoCodice		-- se ricoverato=1: codice del reparto di degenza, se ricoverato=0 = reparto di dimissione
				, @RepartoDescr AS RepartoDescr			-- se ricoverato=1: descrizione del reparto di degenza, se ricoverato=0 ->= desc del reparto di dimissione
				, @SettoreCodice AS SettoreCodice		-- codice del settore di degenza - come sopra
				, @SettoreDescr  AS SettoreDescr		-- descrizione del settore di degenza - come sopra
				, @LettoCodice AS LettoCodice			-- codice del letto - come sopra
				, @DataDimissione AS DataDimissione	    -- Data fine episodio
		
		
	END TRY
	BEGIN CATCH
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'Ws2PazienteRiepilogoInfoRicoveroById. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	END CATCH
	
END


