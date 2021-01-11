







CREATE PROCEDURE [ws2].[RicoveriByReparti]
(
	@RepartiRicovero AS RepartiRicovero READONLY
	, @StatoRicovero AS tinyint=NULL			--0=dimessi, 1=ricoverati, 2=dimessi + ricoverati, 3=prenotati
	, @TipoRicoveroCodice AS VARCHAR(16)=NULL	--Valori=O,P,S,D,B,A (valori del campo RicoveriBase.StatoCodice)
	, @DataAccettazioneDal as DATETIME=NULL	
	, @DataAccettazioneAl as DATETIME=NULL		
	, @DataDimissioneDal DATETIME = NULL
	, @DataDimissioneAl DATETIME = NULL
	, @Cognome AS VARCHAR(50)=NULL
	, @Nome AS VARCHAR(50)=NULL
	, @DataNascita AS DATETIME=NULL
	, @LuogoNascita AS VARCHAR(80)=NULL
) WITH RECOMPILE
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveriByReparti
		Filtro per data partizione e filtro per data partizione - ESISTEVA GIA'!!!
		Restituito il campo XML Oscuramenti
		Aggiunto il sistema erogante
		Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista

	Accetta come parametro una table 
	Nuovo metodo per la ricerca dei pazienti ricoverati: 
		1) Filtro per @DataDimissioneDal e @DataDimissioneAl
		2) @RepartoCodice può essere NULL -> ricerca in tutti i reparti
		3) Viene restituito anche 'NumEpisodioOriginePS' -> NumeroNosologicoOrigine
		4) Aggiunto i default ai range di date in base al valore del parametro @StatoRicovero
		5) Per alcune ricerche diventa obbligatorio il cognome del paziente
	E' analoga alla ws2.RicoveriByReparto2, in più accetta il tipo di dato custom @RepartiRicovero AS RepartiRicovero
	e utilizza la DataPartizione.
	In più è stata ottimizzata la ricerca.
	
	MODIFICA ETTORE 2015-11-24: Restituzione dei campi SettoreCodice, SettoreDescr, LettoCodice
	MODIFICA ETTORE 2015-12-02: Restituzione dei nuovi campi RepartoDimissioneCodice, RepartoDimissioneDescr
	MODIFICA ETTORE 2015-12-02: Restituzione dei nuovi campi RepartoDimissioneCodice, RepartoDimissioneDescr	
	MODIFICA ETTORE 2016-05-05: per migliorare le prestazioni con query distribuite
		Uso il sinonimo SAC_Pazienti (vista PazientiOutput del SAC) per ricercare i fusi + join con @PazientiTable
		Filtriamo i ricoveri solo per i pazienti contenuti nella tabella temporanea @PazientiTable, se ce ne sono
		
	MODIFICA ETTORE 2016-05-11: uso vista sac.pazienti
	MODIFICA ETTORE 2016-05-13: 
		Se @RicercaPaziente = 1: Uso function table [sac].[OttienePazientiPerGeneralita] per eseguire ricerca paziente
		Se @RicercaPaziente = 0: Uso CROSS APPLY sac.OttienePazientePerIdSac(IdPazienteAttivo) per cercare i pazienti attivi ottenuti dai ricoveri

	MODIFICA ETTORE 2016-06-30: Se non fornita la Data di accettazione:
				Per ORDINARIO si ricerca indietro di 7 anni
				Per DH e DS si ricerca indietro di 7 anni (DH e DS hanno durata illimitata, limito poichè NON è stata fornita la data di accettazione)
				Per Prenotazioni si ricerca indietro di 7 anni
				Se il tipo di ricovero NON viene passato limito poichè NON è stata fornita la data di accettazione: si ricerca indietro di 7 anni

	MODIFICA ETTORE 2016-09-29: Tolto "OR @TipoRicoveroCodice IS NULL" nel fitro su R.TipoRicoveroCodice perchè altrimenti non usa l'indice

	MODIFICA SANDRO 2016-10-06: Aggiunto OPTION (RECOMPILE) dopo la migrazione a SQL 2014, sembra che WITH RECOMPILE della SP non serva
	MODIFICA ETTORE 2016-12-05: Correzione: aggiunto parametri @DataNascita e @LuogoNascita alla ricerca per gemeralità
	MODIFICA ETTORE 2017-03-14: Gestione nuovo TipoRicoveroCodice (regime): A-Altro
								CORREZIONE: il calcolo della data di partizione era fatto prima di calcolare la data di accettazione minima
								Questo faceva si che per qualsiasi tipo di ricovero si andasse indietro nel tempo al max di 36 mesi
								Se @DataAccettazioneDal non è valorizzata dopo i vari test imposto @DataAccettazioneDal = DATEADD(year, -7, GETDATE())

	
	MODIFICA SANDRO 2017-06-28: Modificato il filtro opzionale su @Pazienti.  Con il patter ( EXISTS @Pazienti OR @Pazienti vuoto) non è efficente
								Usa query con WITH ed esegue delle UNION ALL con vari filtri
	MODIFICA SANDRO 2017-06-28: Introdotto ModalitaRicerca = [Ricoveri | Paziente | RicoveriPaziente]
											Ricoveri = paziente non specificato
											Paziente = paziente con Cognome + Nome > 5
											RicoveriPaziente
	MODIFICA ETTORE: 2017-08-04 : Valorizzazione del campo 'Sesso' nella tabella temporanea @PazientiTable.
	MODIFICA ETTORE 2017-09-26: Restituite anche le prenotazioni "Sospese"
	MODIFICA ETTORE 2018-05-21: Se @StatoRicovero = 0 (=dimessi) e @TipoRicoveroCodice = O (=Ricovero Ordinario) 
								ed è specificato un range di dimissione di max N(=60 giorni) non è obbligatorio 
								valorizzare il cognome del paziente
	MODIFICA ETTORE 2020-02-07: Usato join fra ws2.Ricoveri e store.RicoveriBase per migliorare le prestazioni
								Nella parte di filtro usare store.RicoveriBase e restituire i campi di ws2.Ricoveri
	MODIFICA ETTORE 2020-04-30: Rimosso la join con codice nullo del reparto viene fatta dalla SP ws2.RicoveriByReparti_Estesa
								Chiamata la SP ws2.RicoveriByReparti_Estesa in caso di presenza codice NULL nel parametro @RepartiRicovero
								Tolto la join con la store.Ricoveri
*/
	SET NOCOUNT ON; 
	--
	-- Se la ricerca è su tutti i reparti di un azienda eseguo la versione estesa
	--
	IF EXISTS(SELECT * FROM @RepartiRicovero WHERE Codice IS NULL) 
	BEGIN
		EXEC [ws2].[RicoveriByReparti_Estesa] 
							   @RepartiRicovero
							  ,@StatoRicovero
							  ,@TipoRicoveroCodice
							  ,@DataAccettazioneDal
							  ,@DataAccettazioneAl
							  ,@DataDimissioneDal
							  ,@DataDimissioneAl
							  ,@Cognome
							  ,@Nome
							  ,@DataNascita
							  ,@LuogoNascita
		RETURN
	END
	--
	--
	--
	DECLARE @T0 DATETIME --Per debug: per calcolare tempo totale	
	DECLARE @T1 DATETIME --Per debug: per calcolare tempi intermedi
	SET @T0 = GETDATE()

    DECLARE @ModalitaRicerca VARCHAR(16)
    SET @ModalitaRicerca = 'Ricoveri'
	--
	-- Aggiusto i parametri
	--
	IF LTRIM(RTRIM(@Cognome)) = '' SET @Cognome = NULL
	IF LTRIM(RTRIM(@Nome)) = '' SET @Nome = NULL
	IF LTRIM(RTRIM(@LuogoNascita)) = '' SET @LuogoNascita = NULL
	IF LTRIM(RTRIM(@TipoRicoveroCodice)) = '' SET @TipoRicoveroCodice = NULL
	IF @StatoRicovero IS NULL SET @StatoRicovero = 2 --Ricoveri: Dimessi + In reparto
	--
	-- Imposto il massimo numero di giorni del range di dimissione per la non obbligatorietà del cognome in caso di ricerca di dimessi da ricoveri ordinari
	--
	DECLARE @RangeDimissione_MaxNumDays INTEGER
	SELECT @RangeDimissione_MaxNumDays = ISNULL([dbo].[GetConfigurazioneInt] ('WS-Ricoverati','RangeDimissione_MaxDays') , 60)	
	
	--
	-- Limitazione record restituiti
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Ricoveri') , 2000)	
	--
	-- Controlli
	--
	IF @TipoRicoveroCodice IS NULL 
	BEGIN
		RAISERROR('Il campo @TipoRicoveroCodice è obbligatorio. I valori possibili sono O=Ordinario,P=Pronto soccorso,D=Day Hospital,S=Day Service,B=OBI', 16, 1)
		RETURN
	END
	IF @TipoRicoveroCodice IN ('D', 'S') AND (ISNULL(@Cognome, '') = '') 
	BEGIN
		RAISERROR('Se il tipo ricovero è ''DAY HOSPITAL'' o ''DAY SERVICE'' il cognome del paziente è obbligatorio.', 16, 1)
		RETURN
	END
	IF @StatoRicovero = 3  AND (ISNULL(@Cognome, '') = '') 
	BEGIN
		RAISERROR('Per la ricerca di PRENOTAZIONI il cognome del paziente è obbligatorio.', 16, 1)
		RETURN
	END
	--IF @StatoRicovero IN (0,2) AND (ISNULL(@Cognome, '') = '') --dimessi o in reparto e dimessi
	--BEGIN	
	--	RAISERROR('Per la ricerca dei pazienti sia IN REPARTO che DIMESSI oppure solo DIMESSI il cognome del paziente è obbligatorio.', 16, 1)
	--	RETURN
	--END
	IF @StatoRicovero IN (0) --Solo DIMESSI
	BEGIN 
		--Solo per la ricerca di ricoveri ORDINARI con [range data dimissione] <= @RangeDimissione_MaxNumDays il cognome non è obbligatorio
		IF NOT ( NOT @DataDimissioneDal IS NULL AND NOT @DataDimissioneAl IS NULL 
				AND @TipoRicoveroCodice = 'O'  AND DATEDIFF(day, @DataDimissioneDal, @DataDimissioneAl) <= @RangeDimissione_MaxNumDays)
			AND (ISNULL(@Cognome, '') = '') 
		BEGIN
			DECLARE @Msg as VARCHAR(200) 
			SET @Msg = 'Per la ricerca dei pazienti DIMESSI il cognome del paziente è obbligatorio se @TipoRicoveroCodice <> ''O'' o  il range di data di dimissione > di ' + CAST(@RangeDimissione_MaxNumDays AS VARCHAR(10)) + ' giorni'
			RAISERROR(@Msg , 16, 1)
			RETURN
		END 
	END

	IF @StatoRicovero IN (2) AND (ISNULL(@Cognome, '') = '') --dimessi o in reparto e dimessi
	BEGIN	
		RAISERROR('Per la ricerca dei pazienti sia IN REPARTO che DIMESSI il cognome del paziente è obbligatorio.', 16, 1)
		RETURN
	END
	
	----------------------------------------------------------------------------
	-- INIZIO PREPARAZIONE TABELLA TEMPORANEA @TabRicoveroStatiCodice per i possibili stati del ricovero
	----------------------------------------------------------------------------
	--
	-- Preparo la tabella temporanea con i possibili stati del ricovero in base al parametro passato @StatoRicovero
	--
	DECLARE @TabRicoveroStatiCodice AS TABLE (Codice VARCHAR(16))
	IF @StatoRicovero = 0
		INSERT INTO @TabRicoveroStatiCodice (Codice) VALUES (3)
	ELSE
	IF @StatoRicovero = 1
		INSERT INTO @TabRicoveroStatiCodice (Codice) VALUES (1),(2),(4)
	ELSE
	IF @StatoRicovero = 2
		INSERT INTO @TabRicoveroStatiCodice (Codice) VALUES (1),(2),(4),(3)
	ELSE
	IF @StatoRicovero = 3
		INSERT INTO @TabRicoveroStatiCodice (Codice) VALUES (20),(21),(23)
	----------------------------------------------------------------------------
	-- FINE PREPARAZIONE TABELLE TEMPORANEE
	----------------------------------------------------------------------------
	--
	-- Posso eseguire la ricerca per paziente? Devo almeno fornire il cognome per la ricerca del paziente 
	--
    IF (LEN(ISNULL(@Cognome, '') + ISNULL(@Nome, '')) > 5)
		SET @ModalitaRicerca = 'Paziente'
	ELSE IF (ISNULL(@Cognome, '') <> '')
        SET @ModalitaRicerca = 'RicoveriPaziente'

	PRINT 'Modalita ricerca = ' + @ModalitaRicerca
	--
	-- Impostazioni range di date di default
	--
	IF @DataAccettazioneDal IS NULL AND @StatoRicovero IN (1,2) --In reparto/in reparto + dimessi 
	BEGIN
		IF @TipoRicoveroCodice = 'O' SET @DataAccettazioneDal = DATEADD(year, -7, GETDATE()) --MODIFICA ETTORE 2016-06-30: Per ORDINARIO si ricerca indietro di 7 anni
		ELSE
		IF @TipoRicoveroCodice = 'B' SET @DataAccettazioneDal = DATEADD(day, -32, GETDATE()) --un OBI dura al max 1 mese
		ELSE			
		IF @TipoRicoveroCodice = 'P' SET @DataAccettazioneDal = DATEADD(day, -7, GETDATE()) --un P dura al max 3 giorni
		ELSE
		IF @TipoRicoveroCodice IN ('D', 'S') SET @DataAccettazioneDal = DATEADD(year, -7, GETDATE()) --MODIFICA ETTORE 2016-06-30: Per DH e DS si ricerca indietro di 7 anni (DH e DS hanno durata illimitata, limito poichè NON è stata fornita la data di accettazione)
		ELSE
		IF @TipoRicoveroCodice = 'A' SET @DataAccettazioneDal = DATEADD(year, -7, GETDATE()) --MODIFICA ETTORE 2017-03-14: Per A (=Altro) si ricerca indietro di 7 anni
		ELSE 
			SET @DataAccettazioneDal = DATEADD(year, -7, GETDATE()) --MODIFICA ETTORE 2016-06-30: Se il tipo di ricovero NON viene passato limito poichè NON è stata fornita la data di accettazione: si ricerca indietro di 7 anni
	END 
	IF @DataDimissioneDal IS NULL AND @StatoRicovero IN (0,2) --Dimessi/in reparto + dimessi 
		SET @DataDimissioneDal = DATEADD(year, -1, GETDATE()) --I dimessi da un anno
	IF @DataAccettazioneDal IS NULL AND @StatoRicovero IN (3) --Prenotazioni
		SET @DataAccettazioneDal = DATEADD(year, -7, GETDATE()) --MODIFICA ETTORE 2016-06-30: Per Prenotazioni si ricerca indietro di 7 anni
	--
	-- MODIFICA ETTORE 2017-03-14: Se @DataAccettazioneDal non è valorizzata dopo i vari test imposto @DataAccettazioneDal = DATEADD(year, -7, GETDATE())
	--
	IF @DataAccettazioneDal IS NULL 
		SET @DataAccettazioneDal = DATEADD(year, -7, GETDATE())
	--------------------------------------------------------------------------------------------------
	-- Calcolo filtro per data partizione
	--------------------------------------------------------------------------------------------------
	DECLARE @DataPartizioneDal DATETIME
	--A questo punto la @DataAccettazioneDal NON E' NULL
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DataAccettazioneDal)	
	--------------------------------------------------------------------------------------------------			

	--PRINT '@StatoRicovero=' + CAST(@StatoRicovero AS VARCHAR(10))
	--PRINT '@TipoRicoveroCodice=' + ISNULL(@TipoRicoveroCodice, 'NULL')
	--PRINT '@DataAccettazioneDal=' + ISNULL(CONVERT(VARCHAR(20), @DataAccettazioneDal , 120),'NULL')
	--PRINT '@DataDimissioneDal=' + ISNULL(CONVERT(VARCHAR(20), @DataDimissioneDal, 120),'NULL')
	--PRINT '@Cognome=' +  ISNULL(@Cognome, 'NULL') + ' @Nome=' + ISNULL(@Nome, 'NULL')
	--PRINT '@DataPartizioneDal=' + ISNULL(CONVERT(VARCHAR(20), @DataPartizioneDal , 120),'NULL')
	
	--
	-- Dichiaro tabella temporanea con dati di ritorno + colonna IdPazienteAttivo
	-- AGGIUNTO CAMPO NumeroNosologicoOriginePS VARCHAR(64)
	--
	DECLARE @TempRicoveri TABLE (
		IdPaziente UNIQUEIDENTIFIER, IdPazienteAttivo UNIQUEIDENTIFIER, IdRicovero UNIQUEIDENTIFIER NOT NULL, AziendaErogante VARCHAR(16) NOT NULL, SistemaErogante VARCHAR(16) NOT NULL, NumeroNosologico VARCHAR(64) NOT NULL
		, DataAccettazione DATETIME, DataDimissione DATETIME
		, RepartoCodice VARCHAR(16), RepartoDescrizione VARCHAR(128), StatoRicovero VARCHAR(9), TipoRicoveroCodice VARCHAR(16), TipoRicoveroDescr VARCHAR(128)
		, NumeroNosologicoOrigine VARCHAR(64)
		, SettoreCodice VARCHAR(16), SettoreDescr VARCHAR(128), LettoCodice VARCHAR(16)
		, RepartoDimissioneCodice VARCHAR(16), RepartoDimissioneDescr VARCHAR(128)
		, Oscuramenti XML) 

	DECLARE @PazientiTable TABLE (Id UNIQUEIDENTIFIER,Nome VARCHAR(64),Cognome VARCHAR(64)
							,CodiceFiscale VARCHAR(16),DataNascita DATETIME,LuogoNascita VARCHAR(128), Sesso VARCHAR(1))

    IF @ModalitaRicerca = 'Paziente'
	BEGIN
		SET @T1 = GETDATE()

		INSERT INTO @PazientiTable (Id, Nome, Cognome, CodiceFiscale, DataNascita, LuogoNascita, Sesso)
		SELECT Id, UPPER(Nome), UPPER(Cognome), CodiceFiscale, DataNascita, LuogoNascitaDescrizione, Sesso
		FROM [sac].[OttienePazientiPerGeneralita](30000, @Cognome, @Nome, @DataNascita, NULL, @LuogoNascita, NULL)
					
		PRINT 'Ricerca anagrafica per cognome, nome, data nascita, luogo nascita: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'
	END
	--
	-- Ricerca sui ricoveri
	--
	SET @T1 = GETDATE()
	--
    -- Query temporanea tutti i ricoverati
    -- Non mettere qui il TOP(xx), troncherebbe prima
    --
    ;WITH RicoveriSp AS
    (
	SELECT
		R.IdPaziente AS IdPaziente 
		, dbo.GetPazienteAttivoByIdSac(R.IdPaziente) AS IdPazienteAttivo
		, R.Id AS IdRicovero
		, R.AziendaErogante
		, R.SistemaErogante
		, R.NumeroNosologico
		, R.DataAccettazione
		, R.DataDimissione		
		, R.RepartoCodice
		, R.RepartoDescr AS RepartoDescrizione
		-- Stato del ricovero		
		, CASE R.StatoCodice
			WHEN  3 THEN
				'Terminato' 
			ELSE
				'In corso' 		  
		  END AS StatoRicovero
		, R.TipoRicoveroCodice
		, R.TipoRicoveroDescr
		, CONVERT(VARCHAR(64), dbo.GetRicoveriAttributo( R.Id, 'NumEpisodioOriginePS')) AS NumeroNosologicoOrigine
		--
		-- Restituzione nuovi campi SettoreCodice , SettoreDescr , LettoCodice 
		--
		, SettoreCodice , SettoreDescr , LettoCodice 
		--
		-- Nuovi campi: RepartoDimissioneCodice, RepartoDimissioneDescr
		-- Li restituisco solo se il ricovero è in dimissione
		--
		, CASE WHEN NOT DataDimissione IS NULL THEN
			RepartoCodice
		ELSE
			CAST(NULL AS VARCHAR(16))
		END AS RepartoDimissioneCodice
		, CASE WHEN NOT DataDimissione IS NULL THEN
			RepartoDescr
		ELSE
			CAST(NULL AS VARCHAR(128))
		END AS RepartoDimissioneDescr
		--
		-- Restituisco XML con lista degli oscuramenti
		--
		, Oscuramenti
	FROM
		ws2.Ricoveri AS R WITH(NOLOCK)
		INNER JOIN @RepartiRicovero AS Rep
			ON Rep.Azienda = R.AziendaErogante
				AND Rep.Codice = R.RepartoCodice
	WHERE
		EXISTS (SELECT * FROM @TabRicoveroStatiCodice AS TAB WHERE TAB.Codice = R.StatoCodice)
		
		AND (R.TipoRicoveroCodice = @TipoRicoveroCodice)
		AND R.IdPaziente <> '00000000-0000-0000-0000-000000000000'
		AND R.DataPartizione > @DataPartizioneDal				
		AND ( 
				(@StatoRicovero=0 AND R.StatoCodice IN (3) --DIMESSI
					AND (
								(
									(@DataAccettazioneDal <= R.DataAccettazione OR @DataAccettazioneDal IS NULL)
									AND (@DataAccettazioneAl >= R.DataAccettazione OR @DataAccettazioneAl IS NULL)	
								 ) 
								 AND  --QUESTO E' UN AND PERCHE' STO CERCANDO SOLO I DIMESSI E ENTRAMBE LE DATE ESISTONO
								 (
									(@DataDimissioneDal <= R.DataDimissione OR @DataDimissioneDal IS NULL )
									AND (@DataDimissioneAl >= R.DataDimissione OR @DataDimissioneAl IS NULL)	
								 )

						)
				) OR			
				(@StatoRicovero=1 AND R.StatoCodice IN (1,2,4) --IN REPARTO
					AND (
								(
									(@DataAccettazioneDal <= R.DataAccettazione OR @DataAccettazioneDal IS NULL)
									AND (@DataAccettazioneAl >= R.DataAccettazione OR @DataAccettazioneAl IS NULL)	
								 ) 
						)
				) OR 				
				(@StatoRicovero=2 --IN REPARTO E DIMESSI
					AND ( 
							(R.StatoCodice IN (1,2,4) AND --IN REPARTO
								(
									(@DataAccettazioneDal <= R.DataAccettazione OR @DataAccettazioneDal IS NULL)
									AND (@DataAccettazioneAl >= R.DataAccettazione OR @DataAccettazioneAl IS NULL)	
								 ) 

							 )
							 OR --QUESTO E' UN OR PERCHE' STO CERCANDO SIA IN REPARTO CHE DIMESSI, QUINDI LA DATA DI DIMISSIONE NON ESISTE SEMPRE
							 (
								R.StatoCodice IN (3) --DIMESSI
								AND (
									(@DataDimissioneDal <= R.DataDimissione OR @DataDimissioneDal IS NULL )
									AND (@DataDimissioneAl >= R.DataDimissione OR @DataDimissioneAl IS NULL)	
								)
							 )
						)				
				) OR 
				(@StatoRicovero=3 AND R.StatoCodice IN (20,21,23) --Prenotazioni	IN ATTESA/CHIAMATO/SOSPESO
					AND (
								(
									(@DataAccettazioneDal <= R.DataAccettazione OR @DataAccettazioneDal IS NULL)
									AND (@DataAccettazioneAl >= R.DataAccettazione OR @DataAccettazioneAl IS NULL)	
								 ) 
						)
				)
			)
	)

	INSERT INTO @TempRicoveri (IdPaziente, IdPazienteAttivo, IdRicovero , AziendaErogante , SistemaErogante, NumeroNosologico , DataAccettazione , DataDimissione 
		, RepartoCodice , RepartoDescrizione , StatoRicovero , TipoRicoveroCodice , TipoRicoveroDescr, NumeroNosologicoOrigine
		, SettoreCodice , SettoreDescr , LettoCodice 
		, RepartoDimissioneCodice, RepartoDimissioneDescr
		, Oscuramenti) 

	   --MODIFICA SANDRO 2017-06-28: SQL non valuta @PazientiTable, il patter con OR non si può usare
       SELECT TOP(@Top) *
             FROM RicoveriSp R
             WHERE @ModalitaRicerca = 'Paziente'
                    AND EXISTS (SELECT * FROM @PazientiTable P WHERE P.Id = R.IdPaziente)
       UNION ALL
       SELECT TOP(@Top) R.*
             FROM RicoveriSp R INNER JOIN [sac].[Pazienti] P
				ON R.IdPaziente = P.Id

             WHERE @ModalitaRicerca = 'RicoveriPaziente'
				AND Cognome LIKE @Cognome + '%'
				AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
				AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
				AND (LuogoNascitaDescrizione = @LuogoNascita OR @LuogoNascita IS NULL)

       UNION ALL
       SELECT TOP(@Top) *
             FROM RicoveriSp R
             WHERE @ModalitaRicerca = 'Ricoveri'
    ORDER BY R.DataAccettazione DESC
    OPTION (RECOMPILE)

	PRINT 'Ricerca sui ricoveri: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'
	--
	-- Ricerca dei dati del paziente in caso di @RicercaPerPaziente = 0
	--
	IF  @ModalitaRicerca <> 'Paziente'
	BEGIN
		SET @T1 = GETDATE()		
			
		INSERT INTO @PazientiTable (Id, Nome, Cognome, CodiceFiscale, DataNascita, LuogoNascita, Sesso)			
		SELECT DISTINCT P.Id, UPPER(P.Nome), UPPER(P.Cognome), P.CodiceFiscale, P.DataNascita, P.LuogoNascitaDescrizione, P.Sesso
		FROM @TempRicoveri AS TEMP
			CROSS APPLY sac.OttienePazientePerIdSac(TEMP.IdPazienteAttivo) AS P			
			
		PRINT 'Ricerca dati paziente: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'			
	END
	--
	-- Ora eseguo select per restituire i dati e popolare la parte anagrafica del paziente + consenso
	--
	SET @T1 = GETDATE()	
	SELECT 
		Ric.IdPazienteAttivo AS IdPaziente
		, P.Cognome
		, P.Nome
		, P.CodiceFiscale
		, P.DataNascita
		, P.LuogoNascita
		, P.Sesso
		, CASE dbo.GetPazientiConsenso(Ric.IdPazienteAttivo) 
			WHEN 0 THEN CAST(0 AS BIT)  --0=NEGATO, 1=ACCORDATO, NULL=NON RICHIESTO
			WHEN 1 THEN CAST(1 AS BIT)
			WHEN 2 THEN CAST(NULL AS BIT)
			END AS Consenso 
		, Ric.IdRicovero
		, Ric.AziendaErogante
		, Ric.SistemaErogante
		, Ric.NumeroNosologico
		, Ric.DataAccettazione
		, Ric.DataDimissione		
		, Ric.RepartoCodice
		, Ric.RepartoDescrizione
		, Ric.StatoRicovero
		, Ric.TipoRicoveroCodice
		, Ric.TipoRicoveroDescr
		, Ric.NumeroNosologicoOrigine		
		, Ric.SettoreCodice , Ric.SettoreDescr , Ric.LettoCodice 
		, Ric.RepartoDimissioneCodice, Ric.RepartoDimissioneDescr
		, Ric.Oscuramenti
	FROM 
		@TempRicoveri AS Ric
		INNER JOIN @PazientiTable AS P
			ON Ric.IdPazienteAttivo = P.Id

	-- AGGIUNTO dopo l amigrazione a SQL 2014, sembra che WITH RECOMPILE dell aSP non serva
	OPTION (RECOMPILE)

	PRINT 'Restituzione dati: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'		
	PRINT 'Durata totale della query: ' + CAST(DATEDIFF(ms, @T0, GETDATE()) AS VARCHAR(10)) + ' millisecondi'

END

