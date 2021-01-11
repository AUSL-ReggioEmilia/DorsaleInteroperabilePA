


-- =============================================
-- Author:		ETTORE
-- Create date: 2018-10-22
-- Description:	Restituisce elenco dei pazienti transitati in una determinata lista di reparti
--				Restituisce tutti i pazienti che sono stati in un reparto a seguito di A o T (anche se già dimessi)
--				Il parametro @TipoRicoveroCodice può valere: NULL, '', O,P,S,D,B 
-- =============================================
CREATE PROCEDURE [ws3].[PazientiTransitatiByReparti]
(
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER
	, @Ordinamento		VARCHAR(128)				
	, @RepartiRicovero	AS RepartiRicovero READONLY 
	, @TipoRicoveroCodice VARCHAR(16)		--Valori=O,P,S,D,B, NULL, ''
	, @DataDal			DATETIME = NULL
	, @DataAl			DATETIME = NULL
	, @Cognome			VARCHAR(64)=NULL
	, @Nome				VARCHAR(64)	= NULL
	, @DataNascita		DATETIME=NULL
	, @AnnoNascita		INT=NULL
	, @LuogoNascita		VARCHAR(80)=NULL
	, @AziendaEroganteNosologico	VARCHAR(16)	= NULL	--AziendaErogante del nosologico
	, @NumeroNosologico		VARCHAR(64) = NULL			--NumeroNosologico
)
AS
BEGIN
/*
	PER MIGLIORARE LE PRESTAZIONI CON QUERY DISTRIBUITE:
		Se @RicercaPerPaziente = 1: usa la function table [sac].[OttienePazientiPerGeneralita]
		Se @RicercaPerPaziente = 0: usa la vista Sac.Pazienti 
		Filtriamo i ricoveri solo per i pazienti contenuti nella tabella temporanea @PazientiTable, se ce ne sono
*/  
	SET NOCOUNT ON
/*
    -- PER PROVA: CARICO TUTTI I REPARTI  -------------------------------------
	insert into @RepartiRicovero values(N'ASMN',N'620')
	insert into @RepartiRicovero values(N'ASMN',N'0122')
	insert into @RepartiRicovero values(N'ASMN',N'0146')
	insert into @RepartiRicovero values(N'ASMN',N'0165')
	insert into @RepartiRicovero values(N'AUSL',N'0000')
	insert into @RepartiRicovero values(N'ASMN',N'0140')
	insert into @RepartiRicovero values(N'ASMN',N'0256')
	insert into @RepartiRicovero values(N'ASMN',N'0178')
	insert into @RepartiRicovero values(N'ASMN',N'1862')
	insert into @RepartiRicovero values(N'AUSL',N'ON705')
	insert into @RepartiRicovero values(N'ASMN',N'ON705')
	insert into @RepartiRicovero values(N'ASMN',N'131')
	insert into @RepartiRicovero values(N'ASMN',N'2132')

	SET @TipoRicoveroCodice = 'O'	
	SET @DataDal = GETDATE()-30000
	SET @Cognome = 'ro'
	*/
---------------------------------------------------------------------------
  	
	DECLARE @T0 DATETIME = GETDATE()	--Per debug: per calcolare tempo totale
	DECLARE @T1 DATETIME				--Per debug: per calcolare tempi intermedi
	--
	-- Modalita di ricerca
	--
    DECLARE @ModalitaRicerca VARCHAR(16)
    SET @ModalitaRicerca = 'Ricoveri'
	--
	-- Per filtro su @AnnoNascita
	--	
	DECLARE @DataNascitaMin AS DATETIME
	DECLARE @DataNascitaMax AS DATETIME
	SET @DataNascitaMin = CAST(CAST(@AnnoNascita AS VARCHAR(4)) + '-01-01 00:00:00' AS DATETIME)
	SET @DataNascitaMax = CAST(CAST(@AnnoNascita AS VARCHAR(4)) + '-12-31 23:59:59' AS DATETIME)    
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
	PRINT '@ViewAll:' + CAST(@ViewAll AS VARCHAR(10))
	--
	-- Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	PRINT ' @IdRuolo :' + CAST( @IdRuolo  AS VARCHAR(40))
	--
	-- Limitazione records restituiti da database
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Ricoveri') , 2000)	
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top	
	--
	-- Impostazioni range di date di default
	--
	IF @DataDal IS NULL SET @DataDal = DATEADD(DAY, -30, GETDATE()) 
	IF @DataAl  IS NULL SET @DataAl = GETDATE()
	--
	-- Calcolo filtro per data partizione
	-- Se viene passata @DataDal la uso per ottenere IL filtro per data partizione ricoveri
	-- Altrimenti metto un default di -3 anni 
	-- Se @DataPartizioneRicoveriDal è NULL la fisso alla data minima possibile
	--
    DECLARE @DataPartizioneRicoveriDal DATETIME
    SELECT @DataPartizioneRicoveriDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DataDal) 

	IF @DataPartizioneRicoveriDal IS NULL
	  SET @DataPartizioneRicoveriDal = DATEADD(YEAR, -3, GETDATE())
	--
	-- Aggiusto i parametri
	--
	IF LTRIM(RTRIM(@Cognome)) = '' SET @Cognome = NULL
	IF LTRIM(RTRIM(@Nome)) = '' SET @Nome = NULL
	IF LTRIM(RTRIM(@LuogoNascita)) = '' SET @LuogoNascita = NULL
	IF LTRIM(RTRIM(@TipoRicoveroCodice)) = '' SET @TipoRicoveroCodice = NULL
	IF LTRIM(RTRIM(@AziendaEroganteNosologico)) = '' SET @AziendaEroganteNosologico = NULL
	IF LTRIM(RTRIM(@NumeroNosologico)) = '' SET @NumeroNosologico = NULL	

	IF @TipoRicoveroCodice IN ('D', 'S') AND @Cognome IS NULL
	BEGIN
		RAISERROR('Se il tipo ricovero è ''DAY HOSPITAL'' o ''DAY SERVICE'' il cognome del paziente è obbligatorio.', 16, 1)
		RETURN
	END  
	--
	-- Posso eseguire la ricerca per paziente? Devo almeno fornire il cognome per la ricerca del paziente 
	--
	IF (LEN(ISNULL(@Cognome, '') + ISNULL(@Nome, '')) > 7)
		SET @ModalitaRicerca = 'Paziente'
	ELSE IF (ISNULL(@Cognome, '') <> '')
        SET @ModalitaRicerca = 'RicoveriPaziente'

	PRINT 'Modalita ricerca = ' + @ModalitaRicerca	
	--
	-- Dichiaro tabella temporanea con dati di ritorno + colonna IdPazienteAttivo
	--
	DECLARE @PazientiTable TABLE (
		Id UNIQUEIDENTIFIER,Nome VARCHAR(64),Cognome VARCHAR(64)
		,CodiceFiscale VARCHAR(16),DataNascita DATETIME, LuogoNascitaCodice VARCHAR(6), LuogoNascitaDescrizione VARCHAR(128), Sesso VARCHAR(1)
		, CodiceSanitario VARCHAR(16)
		, DomicilioComuneCodice VARCHAR(6), DomicilioComuneDescrizione VARCHAR(128)
		, DomicilioCap VARCHAR(8), DomicilioIndirizzo VARCHAR(256)
		, ConsensoAziendaleCodice TINYINT, ConsensoAziendaleDescrizione VARCHAR(64), ConsensoAziendaleData DATETIME
		, DataDecesso DATETIME
		)	

	DECLARE @EventiTable TABLE 
	(	AziendaErogante VARCHAR(16) NOT NULL,
		NumeroNosologico VARCHAR(64) NOT NULL,
		DataEvento DATETIME,
		IdPazienteAttivo UNIQUEIDENTIFIER,
		IdPaziente UNIQUEIDENTIFIER,
		TipoEventoCodice VARCHAR(16),
		TipoEventoDescr VARCHAR(64),
		RepartoCodice VARCHAR(16),
		RepartoDescr VARCHAR(64)
	)

	--
	-- Ricerca su SAC
	--
	IF @ModalitaRicerca = 'Paziente' 
	BEGIN     
		SET @T1 = GETDATE()
		--
		-- Ricavo dalla function table [sac].[OttienePazientiPerGeneralita] gli Id dei record attivi e fusi che matchano la ricerca anagrafica
		--								 
		INSERT INTO @PazientiTable(Id, Nome, Cognome, CodiceFiscale, DataNascita)
		SELECT Id, Nome, Cognome, CodiceFiscale, DataNascita
		FROM [sac].[OttienePazientiPerGeneralita](30000, @Cognome, @Nome, @DataNascita, @AnnoNascita, @LuogoNascita , NULL)
		              
		PRINT 'Ricerca anagrafica: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' ms'
	END
	--
	-- Ricerca sugli eventi
	--
	SET @T1 = GETDATE()
	--
    -- Query temporanea tutti i ricoverati
    -- Non mettere qui il TOP(xx), troncherebbe prima
    --
    ;WITH EventiSp AS
    (
	SELECT
		Ev.AziendaErogante
		, Ev.NumeroNosologico
		, Ev.DataEvento
		, dbo.GetPazienteAttivoByIdSac(Ev.IdPaziente) AS IdPazienteAttivo
		, Ev.IdPaziente
		, Ev.TipoEventoCodice
		, Ev.TipoEventoDescr
		, Ev.RepartoCodice
		, Ev.RepartoDescr
	FROM 
		ws3.Eventi AS Ev WITH(NOLOCK)
	WHERE
		--
		-- Filtro SOLO le Unita Operative
		--
		(
			(@ViewAll = 1) 
			OR 
			(
				EXISTS( SELECT * FROM dbo.OttieniUnitaOperativePerToken(@IdToken) AS Rep
					WHERE Rep.UnitaOperativaAzienda = Ev.AziendaErogante AND Rep.UnitaOperativaCodice = Ev.RepartoCodice)
			)
		) 	
		AND 
		Ev.TipoEventoCodice IN ('A','T')
		AND (Ev.TipoEpisodio = @TipoRicoveroCodice OR @TipoRicoveroCodice IS NULL)
		
		--Eventuale filtro sul nosologico		
		AND (
			(Ev.AziendaErogante = @AziendaEroganteNosologico OR @AziendaEroganteNosologico IS NULL)
			AND 
			(Ev.NumeroNosologico = @NumeroNosologico OR @NumeroNosologico IS NULL)
			)

		AND Ev.IdPaziente <> '00000000-0000-0000-0000-000000000000'
		AND (Ev.DataPartizione >= @DataPartizioneRicoveriDal)
		AND Ev.DataEvento BETWEEN @DataDal AND @DataAl
		--
		-- Filtro per i reparti richiesti
		--
		AND ( 
			EXISTS (SELECT * FROM @RepartiRicovero AS TAB WHERE TAB.Azienda = Ev.AziendaErogante 
						AND TAB.Codice= Ev.RepartoCodice ) 
				OR	NOT EXISTS (SELECT * FROM @RepartiRicovero)
			)
	)

	INSERT INTO @EventiTable 
	(	AziendaErogante
		, NumeroNosologico
		, DataEvento
		, IdPazienteAttivo
		, IdPaziente
		, TipoEventoCodice
		, TipoEventoDescr
		, RepartoCodice
		, RepartoDescr
	)
       SELECT TOP(@MaxNumRow) *
             FROM EventiSp R
             WHERE @ModalitaRicerca = 'Paziente'
                    AND EXISTS (SELECT * FROM @PazientiTable P WHERE P.Id = R.IdPaziente)
       UNION ALL
       SELECT TOP(@MaxNumRow) R.*
             FROM EventiSp R INNER JOIN [sac].[Pazienti] P
				ON R.IdPaziente = P.Id

             WHERE @ModalitaRicerca = 'RicoveriPaziente'
				AND Cognome LIKE @Cognome + '%'
				AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
				AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
				AND (LuogoNascitaDescrizione = @LuogoNascita OR @LuogoNascita IS NULL)
				AND (DataNascita BETWEEN @DataNascitaMin AND @DataNascitaMax OR @AnnoNascita IS NULL)

       UNION ALL
       SELECT TOP(@MaxNumRow) *
             FROM EventiSp R
             WHERE @ModalitaRicerca = 'Ricoveri'

    ORDER BY R.DataEvento DESC
    OPTION (RECOMPILE)

	PRINT 'Ricerca sugli eventi : ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' ms'
	--
	-- Completo i dati del paziente con le info del paziente ATTIVO della fusione
	-- Integro e inserisco a seconda del la modalità di ricerca
	--
	IF  @ModalitaRicerca <> 'Paziente'
	BEGIN
		PRINT '@ModalitaRicerca <> ''Paziente'''
		SET @T1 = GETDATE()
			
		INSERT INTO @PazientiTable(Id, Nome, Cognome, CodiceFiscale, DataNascita, LuogoNascitaCodice, LuogoNascitaDescrizione, Sesso
			, DomicilioComuneCodice, DomicilioComuneDescrizione, DomicilioCap, DomicilioIndirizzo
			, ConsensoAziendaleCodice , ConsensoAziendaleDescrizione, ConsensoAziendaleData, DataDecesso)
		SELECT DISTINCT --ATTENZIONE: la join con gli eventi genera righe doppie per i pazienti
			Id, UPPER(Nome), UPPER(Cognome), CodiceFiscale, DataNascita, LuogoNascitaCodice, LuogoNascitaDescrizione, Sesso
			, DomicilioComuneCodice, DomicilioComuneDescrizione, DomicilioCap, DomicilioIndirizzo
			, ConsensoAziendaleCodice, ConsensoAziendaleDescrizione, ConsensoAziendaleData, DataDecesso					

		FROM @EventiTable AS TEMP
			CROSS APPLY sac.OttienePazientePerIdSac(TEMP.IdPazienteAttivo) AS P			
		
		PRINT 'Ricerca dati paziente: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'
						
	END ELSE BEGIN
		PRINT '@ModalitaRicerca = ''Paziente'''	
		SET @T1 = GETDATE()		

		UPDATE @PazientiTable
		SET LuogoNascitaCodice = P.LuogoNascitaCodice
			, LuogoNascitaDescrizione = P.LuogoNascitaDescrizione
			, Sesso = P.Sesso
			, DomicilioComuneCodice = P.DomicilioComuneCodice
			, DomicilioComuneDescrizione = P.DomicilioComuneDescrizione
			, DomicilioCap = P.DomicilioCap
			, DomicilioIndirizzo = P.DomicilioIndirizzo
			, ConsensoAziendaleCodice = P.ConsensoAziendaleCodice
			, ConsensoAziendaleDescrizione = P.ConsensoAziendaleDescrizione
			, ConsensoAziendaleData = P.ConsensoAziendaleData
			, DataDecesso = P.DataDecesso

		FROM 
			@EventiTable AS Ev  --la join con @EventiTable limita le chiamate alla sac.OttienePazientePerIdSac()
			INNER JOIN @PazientiTable AS TEMP
				ON Ev.IdPazienteAttivo = TEMP.Id
			OUTER APPLY sac.OttienePazientePerIdSac(TEMP.Id) AS P			
			
		PRINT 'Integra dati paziente: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'			
	END

	--
	-- Restituzione dei dati
	--        
	SET @T1 = GETDATE()

	SELECT 
		Ev.IdPazienteAttivo as Id
		, P.Cognome AS Cognome		
		, P.Nome AS Nome
		, P.CodiceFiscale
		, P.DataNascita 
		, P.Sesso
		, P.LuogoNascitaCodice
		, P.LuogoNascitaDescrizione
		, P.CodiceSanitario
		, P.DomicilioComuneCodice AS ComuneDomicilioCodice
		, P.DomicilioComuneDescrizione  AS ComuneDomicilioDescrizione
		, P.DomicilioCap AS ComuneDomicilioCap
		, P.DomicilioIndirizzo AS IndirizzoDomicilio
		, P.DataDecesso
		, P.ConsensoAziendaleCodice
		, P.ConsensoAziendaleDescrizione
		, P.ConsensoAziendaleData
		--
		-- Prendo i dati di AnteprimaReferti e li scrivo in campi strutturati
		--
		,AR.NumeroReferti
		,AR.UltimoRefertoSistemaErogante
		,AR.UltimoRefertoData
		--		
		-- Informazioni sull'ultimo ricovero		
		--
		, Ric.Categoria AS EpisodioCategoria
		, Ric.NumeroNosologicoOrigine AS EpisodioNumeroNosologicoOrigine
		-- Info ricovero
		, Ric.TipoRicoveroCodice AS EpisodioTipoCodice
		, Ric.TipoRicoveroDescr AS EpisodioTipoDescrizione
		--Stato del ricovero corrente (Dimesso, Ricoverato, Trasferito, In Prenotazione)		
		, Ric.StatoCodice  AS EpisodioStatoCodice
		, Ric.StatoDescrizione  AS EpisodioStatoDescrizione
		, Ric.AziendaErogante AS EpisodioAziendaErogante
		, Ric.NumeroNosologico AS EpisodioNumeroNosologico
		, Ric.DataAccettazione AS EpisodioDataApertura
		, Ric.DataTrasferimento AS EpisodioDataUltimoEvento
		, Ric.DataDimissione AS EpisodioDataConclusione
		, Ric.RepartoAccettazioneCodice AS EpisodioStrutturaAperturaCodice
		, Ric.RepartoAccettazioneDescr AS EpisodioStrutturaAperturaDescrizione
		, Ric.RepartoCorrenteCodice AS EpisodioStrutturaUltimoEventoCodice
		, Ric.RepartoCorrenteDescr AS EpisodioStrutturaUltimoEventoDescrizione
		, Ric.RepartoDimissioneCodice AS EpisodioStrutturaConclusioneCodice
		, Ric.RepartoDimissioneDescr AS EpisodioStrutturaConclusioneDescrizione
		, Ric.SettoreCodice AS EpisodioSettoreCodice
		, Ric.SettoreDescr AS EpisodioSettoreDescrizione
		, Ric.LettoCodice AS EpisodioLettoCodice
		--
		-- Restituisco i dati di anteprima per le note anamnestiche
		--
		, PA.NumeroNoteAnamnestiche
		, PA.UltimaNotaAnamnesticaData
		, PA.UltimaNotaAnamnesticaSistemaEroganteDescr
		--
		-- Tutti i dati di transito nei reparti passati nel parametro
		--
		, Ev.TipoEventoCodice AS TipoEventoTransitoCodice
		, Ev.TipoEventoDescr AS TipoEventoTransitoDescrizione
		, Ev.DataEvento AS DataTransito
		, Ev.RepartoCodice AS StrutturaTransitoCodice
		, Ev.RepartoDescr AS StrutturaTransitoDescrizione

	FROM 
		ws3.Ricoveri Ric  WITH(NOLOCK)
		INNER JOIN @EventiTable Ev
			ON Ev.AziendaErogante  = Ric.AziendaErogante
			   AND  Ev.NumeroNosologico = Ric.NumeroNosologico
		--	
		-- Faccio join con la tabella temporanea che contiene già tutti i dati
		-- @PazientiTable contiene sia attivi che fusi ma faccio join con i soli attivi	
		--
		INNER JOIN @PazientiTable P
		  ON P.Id = Ev.IdPazienteAttivo
		LEFT OUTER JOIN dbo.PazientiAnteprima AS PA
			ON PA.IdPaziente = P.Id
		OUTER APPLY dbo.ParseAnteprimaReferti(PA.AnteprimaReferti) AS AR
		
	WHERE
		--
		-- Filtro SOLO gli Oscuramenti
		--
		(
			(@ViewAll = 1) 
			OR 
			(
				([dbo].[CheckRicoveroOscuramenti](@IdRuolo, Ev.AziendaErogante, Ev.NumeroNosologico) = 1)
			)
		) 	
		AND
		Ric.DataPartizione > @DataPartizioneRicoveriDal
	ORDER BY 
	--Default 
	CASE @Ordinamento WHEN '' THEN P.Cognome END DESC
	, CASE @Ordinamento WHEN '' THEN P.Nome END DESC
	--Ascendente
	, CASE @Ordinamento  WHEN 'Id@ASC' THEN Ev.IdPazienteAttivo END ASC
    , CASE @Ordinamento  WHEN 'Cognome@ASC' THEN P.Cognome END ASC
    , CASE @Ordinamento  WHEN 'Nome@ASC' THEN P.Nome END ASC
    , CASE @Ordinamento  WHEN 'CodiceFiscale@ASC' THEN P.CodiceFiscale END ASC
    , CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN P.DataNascita END ASC
    , CASE @Ordinamento  WHEN 'Sesso@ASC' THEN P.Sesso END ASC    
    , CASE @Ordinamento  WHEN 'LuogoNascitaCodice@ASC' THEN P.LuogoNascitaCodice END ASC
	, CASE @Ordinamento  WHEN 'LuogoNascitaDescrizione@ASC' THEN P.LuogoNascitaDescrizione END ASC    
    , CASE @Ordinamento  WHEN 'CodiceSanitario@ASC' THEN P.CodiceSanitario END ASC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCodice@ASC' THEN P.DomicilioComuneCodice END ASC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioDescrizione@ASC' THEN P.DomicilioComuneDescrizione END ASC    
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCAP@ASC' THEN P.DomicilioCAP END ASC
    , CASE @Ordinamento  WHEN 'IndirizzoDomicilio@ASC' THEN P.DomicilioIndirizzo END ASC    
    , CASE @Ordinamento  WHEN 'DataDecesso@ASC' THEN P.DataDecesso END ASC    
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleCodice@ASC' THEN P.ConsensoAziendaleCodice END ASC		
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleDescrizione@ASC' THEN P.ConsensoAziendaleDescrizione END ASC		    
	, CASE @Ordinamento  WHEN 'ConsensoAziendaleData@ASC' THEN P.ConsensoAziendaleData END ASC		        
	, CASE @Ordinamento  WHEN 'NumeroReferti@ASC' THEN AR.NumeroReferti END ASC
	, CASE @Ordinamento  WHEN 'UltimoRefertoSistemaErogante@ASC' THEN AR.UltimoRefertoSistemaErogante END ASC
    , CASE @Ordinamento  WHEN 'UltimoRefertoData@ASC' THEN AR.UltimoRefertoData END ASC
    , CASE @Ordinamento  WHEN 'EpisodioCategoria@ASC' THEN Ric.Categoria END ASC
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologicoOrigine@ASC' THEN Ric.NumeroNosologicoOrigine END ASC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoCodice@ASC' THEN Ric.TipoRicoveroCodice END ASC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoDescrizione@ASC' THEN Ric.TipoRicoveroDescr END ASC		        
    , CASE @Ordinamento  WHEN 'EpisodioStatoCodice@ASC' THEN Ric.StatoCodice END ASC
	, CASE @Ordinamento  WHEN 'EpisodioStatoDescrizione@ASC' THEN Ric.StatoDescrizione END ASC
    , CASE @Ordinamento  WHEN 'EpisodioAziendaErogante@ASC' THEN Ric.AziendaErogante END ASC
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologico@ASC' THEN Ric.NumeroNosologico END ASC    
    , CASE @Ordinamento  WHEN 'EpisodioDataApertura@ASC' THEN Ric.DataAccettazione END ASC			
    , CASE @Ordinamento  WHEN 'EpisodioDataUltimoEvento@ASC' THEN Ric.DataTrasferimento END ASC			
    , CASE @Ordinamento  WHEN 'EpisodioDataConclusione@ASC' THEN Ric.DataDimissione END ASC			    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaCodice@ASC' THEN Ric.RepartoAccettazioneCodice END ASC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaDescrizione@ASC' THEN Ric.RepartoAccettazioneDescr END ASC		    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoCodice@ASC' THEN Ric.RepartoCorrenteCodice END ASC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoDescrizione@ASC' THEN Ric.RepartoCorrenteDescr END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneCodice@ASC' THEN Ric.RepartoDimissioneCodice END ASC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneDescrizione@ASC' THEN Ric.RepartoDimissioneDescr END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreCodice@ASC' THEN Ric.SettoreCodice END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreDescrizione@ASC' THEN Ric.SettoreDescr END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioLettoCodice@ASC' THEN Ric.LettoCodice END ASC   
    , CASE @Ordinamento  WHEN 'NumeroNoteAnamnestiche@ASC' THEN PA.NumeroNoteAnamnestiche END ASC   
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaData@ASC' THEN PA.UltimaNotaAnamnesticaData END ASC   
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaSistemaEroganteDescr@ASC' THEN PA.UltimaNotaAnamnesticaSistemaEroganteDescr END ASC   
    , CASE @Ordinamento  WHEN 'TipoEventoTransitoCodice@ASC' THEN Ev.TipoEventoCodice END ASC   
	, CASE @Ordinamento  WHEN 'TipoEventoTransitoDescrizione@ASC' THEN Ev.TipoEventoDescr END ASC   
	, CASE @Ordinamento  WHEN 'DataTransito@ASC' THEN Ev.DataEvento END ASC   
	, CASE @Ordinamento  WHEN 'StrutturaTransitoCodice@ASC' THEN Ev.RepartoCodice END ASC   
	, CASE @Ordinamento  WHEN 'StrutturaTransitoDescrizione@ASC' THEN Ev.RepartoDescr END ASC   

	--Discendente
	, CASE @Ordinamento  WHEN 'IdPaziente@DESC' THEN Ev.IdPazienteAttivo END DESC
    , CASE @Ordinamento  WHEN 'Cognome@DESC' THEN P.Cognome END DESC
    , CASE @Ordinamento  WHEN 'Nome@DESC' THEN P.Nome END DESC
    , CASE @Ordinamento  WHEN 'CodiceFiscale@DESC' THEN P.CodiceFiscale END DESC
    , CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN P.DataNascita END DESC
    , CASE @Ordinamento  WHEN 'Sesso@DESC' THEN P.Sesso END DESC    
    , CASE @Ordinamento  WHEN 'LuogoNascitaCodice@DESC' THEN P.LuogoNascitaCodice END DESC
	, CASE @Ordinamento  WHEN 'LuogoNascitaDescrizione@DESC' THEN P.LuogoNascitaDescrizione END DESC    
    , CASE @Ordinamento  WHEN 'CodiceSanitario@DESC' THEN P.CodiceSanitario END DESC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCodice@DESC' THEN P.DomicilioComuneCodice END DESC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioDescrizione@DESC' THEN P.DomicilioComuneDescrizione END DESC    
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCAP@DESC' THEN P.DomicilioCAP END DESC
    , CASE @Ordinamento  WHEN 'IndirizzoDomicilio@DESC' THEN P.DomicilioIndirizzo END DESC    
    , CASE @Ordinamento  WHEN 'DataDecesso@DESC' THEN P.DataDecesso END DESC    
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleCodice@DESC' THEN P.ConsensoAziendaleCodice END DESC		
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleDescrizione@DESC' THEN P.ConsensoAziendaleDescrizione END DESC		    
	, CASE @Ordinamento  WHEN 'ConsensoAziendaleData@DESC' THEN P.ConsensoAziendaleData END DESC		        
	, CASE @Ordinamento  WHEN 'NumeroReferti@DESC' THEN AR.NumeroReferti END DESC
	, CASE @Ordinamento  WHEN 'UltimoRefertoSistemaErogante@DESC' THEN AR.UltimoRefertoSistemaErogante END DESC
    , CASE @Ordinamento  WHEN 'UltimoRefertoData@DESC' THEN AR.UltimoRefertoData END DESC
    , CASE @Ordinamento  WHEN 'EpisodioCategoria@DESC' THEN Ric.Categoria END DESC
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologicoOrigine@DESC' THEN Ric.NumeroNosologicoOrigine END DESC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoCodice@DESC' THEN Ric.TipoRicoveroCodice END DESC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoDescrizione@DESC' THEN Ric.TipoRicoveroDescr END DESC		        
    , CASE @Ordinamento  WHEN 'EpisodioStatoCodice@DESC' THEN Ric.StatoCodice END DESC
	, CASE @Ordinamento  WHEN 'EpisodioStatoDescrizione@DESC' THEN Ric.StatoDescrizione END DESC
    , CASE @Ordinamento  WHEN 'EpisodioAziendaErogante@DESC' THEN Ric.AziendaErogante END DESC
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologico@DESC' THEN Ric.NumeroNosologico END DESC    
    , CASE @Ordinamento  WHEN 'EpisodioDataApertura@DESC' THEN Ric.DataAccettazione END DESC			
    , CASE @Ordinamento  WHEN 'EpisodioDataUltimoEvento@DESC' THEN Ric.DataTrasferimento END DESC			
    , CASE @Ordinamento  WHEN 'EpisodioDataConclusione@DESC' THEN Ric.DataDimissione END DESC			    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaCodice@DESC' THEN Ric.RepartoAccettazioneCodice END DESC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaDescrizione@DESC' THEN Ric.RepartoAccettazioneDescr END DESC		    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoCodice@DESC' THEN Ric.RepartoCorrenteCodice END DESC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoDescrizione@DESC' THEN Ric.RepartoCorrenteDescr END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneCodice@DESC' THEN Ric.RepartoDimissioneCodice END DESC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneDescrizione@DESC' THEN Ric.RepartoDimissioneDescr END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreCodice@DESC' THEN Ric.SettoreCodice END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreDescrizione@DESC' THEN Ric.SettoreDescr END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioLettoCodice@DESC' THEN Ric.LettoCodice END DESC   
    , CASE @Ordinamento  WHEN 'NumeroNoteAnamnestiche@DESC' THEN PA.NumeroNoteAnamnestiche END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaData@DESC' THEN PA.UltimaNotaAnamnesticaData END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaSistemaEroganteDescr@DESC' THEN PA.UltimaNotaAnamnesticaSistemaEroganteDescr END DESC
    , CASE @Ordinamento  WHEN 'TipoEventoTransitoCodice@DESC' THEN Ev.TipoEventoCodice END DESC
	, CASE @Ordinamento  WHEN 'TipoEventoTransitoDescrizione@DESC' THEN Ev.TipoEventoDescr END DESC
	, CASE @Ordinamento  WHEN 'DataTransito@DESC' THEN Ev.DataEvento END DESC
	, CASE @Ordinamento  WHEN 'StrutturaTransitoCodice@DESC' THEN Ev.RepartoCodice END DESC
	, CASE @Ordinamento  WHEN 'StrutturaTransitoDescrizione@DESC' THEN Ev.RepartoDescr END DESC

	PRINT 'Restituzione dati: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' ms'           
	PRINT 'Durata totale della query: ' + CAST(DATEDIFF(ms, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'
     
END