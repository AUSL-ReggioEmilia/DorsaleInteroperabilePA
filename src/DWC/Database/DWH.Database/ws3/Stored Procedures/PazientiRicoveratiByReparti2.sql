





-- =============================================
-- Author:		ETTORE
-- Create date: 2016-03-17
-- Description:	Restituisce i pazienti ricoverati
-- Modify date: 2016-06-30 - ETTORE : Se non fornita la Data di accettazione:
--									Per ORDINARIO si ricerca indietro di 7 anni
--									Per DH e DS si ricerca indietro di 7 anni (DH e DS hanno durata illimitata, limito poichè NON è stata fornita la data di accettazione)
--									Per Prenotazioni si ricerca indietro di 7 anni
--									Se il tipo di ricovero NON viene passato limito poichè NON è stata fornita la data di accettazione: si ricerca indietro di 7 anni
-- Modify date: 2016-09-29 - ETTORE: Tolto "OR @TipoRicoveroCodice IS NULL" nel fitro su R.TipoRicoveroCodice perchè altrimenti non usa l'indice
-- Modify date: 2016-10-06 - SANDRO : Aggiunto OPTION (RECOMPILE) dopo la migrazione a SQL 2014, sembra che WITH RECOMPILE della SP non serva
--CREATA VERSIONE 2 DA ETTORE 2016-10-17: Restituzione nuovi campi StatoCodice e StatoDescrizione al posto del campo Stato (equivalente a StatoDescrizione)
-- Modify date: 2016-11-30 - SANDRO: Ricerca dati paziente in due parti perchè  la ricerca dei consensi è onerosa
-- Modify date: 2017-03-14 - ETTORE: Gestione nuovo TipoRicoveroCodice (regime): A-Altro
--									Se @DataAccettazioneDal non è valorizzata dopo i vari test imposto @DataAccettazioneDal = DATEADD(year, -7, GETDATE())
-- Modify date: 2017-05-16 - ETTORE: Modificato il TOP nella ricerca pazienti da 10000 a 30000
-- Modify date: 2017-06-28 - SANDRO: Modificato il filtro opzionale su @Pazienti.  Con il patter ( EXISTS @Pazienti OR @Pazienti vuoto) non è efficente
--									 Usa query con WITH ed esegue delle UNION ALL con vari filtri
-- Modify date: 2017-06-28 - SANDRO: Introdotto ModalitaRicerca = [Ricoveri | Paziente | RicoveriPaziente]
--										Ricoveri = paziente non specificato
--										Paziente = paziente con Cognome + Nome > 5
--										RicoveriPaziente
-- Modify date: 2017-07-11 - ETTORE: Aggiunto il filtro su oscuramenti
-- Modify date: 2017-10-12 - ETTORE: Aggiunto join con la tabella @TempRicoveri nella parte 'Integra dati paziente'
--										Numero di caratteri per eseguire @ModalitaRicerca = 'Paziente': > 7
-- Modify date: 2017-09-26 - ETTORE: Restituite anche le prenotazioni "Sospese"
-- Modify date: 2017-11-21 - ETTORE: Aggiunto i campi di anteprima delle note anamnestiche
-- Modify date: 2018-05-21 - ETTORE: Se @StatoRicovero = 0 (=dimessi) e @TipoRicoveroCodice = O (=Ricovero Ordinario) 
--										ed è specificato un range di dimissione di max N(=60 giorni) non è obbligatorio 
--										valorizzare il cognome del paziente
-- Modify date: 2019-01-22 - ETTORE: Se "@ModalitaRicerca <> 'Paziente'" aggiunto DISTINCT nella SELECT per popolare @PazientiTable
--									 Se un paziente ha più ricoveri aperti viene restituito due volte il suo IdPaziente
-- =============================================
CREATE PROCEDURE [ws3].[PazientiRicoveratiByReparti2]
(
	@IdToken				UNIQUEIDENTIFIER	--per ora non lo uso
	, @MaxNumRow			INTEGER
	, @Ordinamento			VARCHAR(128)
	, @RepartiRicovero		AS RepartiRicovero READONLY
	, @StatoRicovero		TINYINT=NULL		--0=dimessi, 1=ricoverati, 2=dimessi + ricoverati, 3=prenotati
	, @TipoRicoveroCodice	VARCHAR(16)=NULL	--Valori=O,P,S,D,B,A (valori del campo RicoveriBase.StatoCodice)
	, @DataAccettazioneDal	DATETIME=NULL	
	, @DataAccettazioneAl	DATETIME=NULL		
	, @DataDimissioneDal	DATETIME = NULL
	, @DataDimissioneAl		DATETIME = NULL
	, @Cognome				VARCHAR(50)=NULL
	, @Nome					VARCHAR(50)=NULL
	, @DataNascita			DATETIME=NULL
	, @AnnoNascita			INT=NULL	
	, @LuogoNascita			VARCHAR(80)=NULL
	, @AziendaEroganteNosologico	VARCHAR(16)	= NULL	--AziendaErogante del nosologico
	, @NumeroNosologico		VARCHAR(64) = NULL			--NumeroNosologico
) WITH RECOMPILE
AS
BEGIN
/*
	QUESTA E' STATA FATTA PER IL FRONT END
	Accetta come parametro una table 
	Nuovo metodo per la ricerca dei pazienti ricoverati: 
		1) Filtro per @DataDimissioneDal e @DataDimissioneAl
		2) @RepartoCodice può essere NULL -> ricerca in tutti i reparti
		3) Viene restituito anche 'NumEpisodioOriginePS' -> NumeroNosologicoOrigine
			e i dati del consenso
		4) Aggiunto i default ai range di date in base al valore del parametro @StatoRicovero
		5) Per alcune ricerche diventa obbligatorio il cognome del paziente
	E' analoga alla ws2.RicoveriByReparti
	In più è stata ottimizzata la ricerca.
	
	ATTENZIONE: 
		Se @RepartiRicovero è una tabella vuota si deve cercare per tutti i reparti di ricovero associati a @IdToken
		La SP filtra per i reparti di ricovero associati all'@IdToken
		
	PER MIGLIORARE LE PRESTAZIONI CON QUERY DISTRIBUITE:
		Se @RicercaPerPaziente = 1: usa la function table [sac].[OttienePazientiPerGeneralita]
		Se @RicercaPerPaziente = 0: usa la vista Sac.Pazienti 
		Filtriamo i ricoveri solo per i pazienti contenuti nella tabella temporanea @PazientiTable, se ce ne sono
		
	Non restituisco il campo Anteprima ma le sue parti come campi strutturati:
		NumeroReferti, UltimoRefertoData, UltimoRefertoSistemaErogante (li valorizzo andandoli a leggere facendo un parsing del campo PazientiAnteprima.AnteprimaReferti)
	I dati dell'ultimo ricovero li ricavo attraverso il campo PazientiRiepilogo.IdUltimoRicovero

*/
	SET NOCOUNT ON; 
	DECLARE @T0 DATETIME --Per debug: per calcolare tempo totale	
	DECLARE @T1 DATETIME --Per debug: per calcolare tempi intermedi
	SET @T0 = GETDATE()
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
	-- MODIFICA ETTORE 2017-07-11: Verifico se al token è associato l'attibuto ATTRIB@VIEW_ALL
	--
	DECLARE @ViewAll as BIT=0
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
	PRINT '@ViewAll:' + CAST(@ViewAll AS VARCHAR(10))
	--
	-- MODIFICA ETTORE 2017-07-11: Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	PRINT ' @IdRuolo :' + CAST( @IdRuolo  AS VARCHAR(40))
	--
	-- Aggiusto i parametri
	--
	IF LTRIM(RTRIM(@Cognome)) = '' SET @Cognome = NULL
	IF LTRIM(RTRIM(@Nome)) = '' SET @Nome = NULL
	IF LTRIM(RTRIM(@LuogoNascita)) = '' SET @LuogoNascita = NULL
	IF LTRIM(RTRIM(@TipoRicoveroCodice)) = '' SET @TipoRicoveroCodice = NULL
	IF LTRIM(RTRIM(@AziendaEroganteNosologico)) = '' SET @AziendaEroganteNosologico	 = NULL
	IF LTRIM(RTRIM(@NumeroNosologico)) = '' SET @NumeroNosologico = NULL	
	IF @StatoRicovero IS NULL SET @StatoRicovero = 2 --Ricoveri: Dimessi + In reparto
	--
	-- Imposto il massimo numero di giorni del range di dimissione per la non obbligatorietà del cognome in caso di ricerca di dimessi da ricoveri ordinari
	--
	DECLARE @RangeDimissione_MaxNumDays INTEGER
	SELECT @RangeDimissione_MaxNumDays = ISNULL([dbo].[GetConfigurazioneInt] ('WS-Ricoverati','RangeDimissione_MaxDays') , 60)	

	--
	-- Limitazione records restituiti da database
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Ricoveri') , 2000)	
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top	
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
	-- INIZIO PREPARAZIONE TABELLA TEMPORANEA @TabRicoveroStatiCodiceParam per i possibili stati del ricovero
	----------------------------------------------------------------------------
	--
	-- Preparo la tabella temporanea con i possibili stati del ricovero in base al parametro passato @StatoRicovero
	--
	DECLARE @TabRicoveroStatiCodiceParam AS TABLE (Codice VARCHAR(16))
	IF @StatoRicovero = 0
		INSERT INTO @TabRicoveroStatiCodiceParam (Codice) VALUES (3)
	ELSE
	IF @StatoRicovero = 1
		INSERT INTO @TabRicoveroStatiCodiceParam (Codice) VALUES (1),(2),(4)
	ELSE
	IF @StatoRicovero = 2
		INSERT INTO @TabRicoveroStatiCodiceParam (Codice) VALUES (1),(2),(4),(3)
	ELSE
	IF @StatoRicovero = 3
		INSERT INTO @TabRicoveroStatiCodiceParam (Codice) VALUES (20),(21),(23)
	----------------------------------------------------------------------------
	-- FINE PREPARAZIONE TABELLE TEMPORANEE
	----------------------------------------------------------------------------
	--
	-- Posso eseguire la ricerca per paziente? Devo almeno fornire il cognome per la ricerca del paziente 
	--
	IF (LEN(ISNULL(@Cognome, '') + ISNULL(@Nome, '')) > 7)
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
		IdPaziente UNIQUEIDENTIFIER NOT NULL, IdPazienteAttivo UNIQUEIDENTIFIER NOT NULL
		, IdRicovero UNIQUEIDENTIFIER NOT NULL
		, AziendaErogante VARCHAR(16) NOT NULL
		, NumeroNosologico VARCHAR(64) NOT NULL
		, DataAccettazione DATETIME, DataTrasferimento DATETIME, DataDimissione DATETIME
		, RepartoAccettazioneCodice VARCHAR(16), RepartoAccettazioneDescr VARCHAR(128)
		, RepartoCorrenteCodice VARCHAR(16), RepartoCorrenteDescr VARCHAR(128)
		, StatoCodice TINYINT --questo è il codice dello stato del ricovero
		, StatoDescrizione VARCHAR(64) --questo è la descrizione dello stato del ricovero
		, TipoRicoveroCodice VARCHAR(16), TipoRicoveroDescr VARCHAR(128)
		, Categoria VARCHAR(16)
		, NumeroNosologicoOrigine VARCHAR(64)
		, SettoreCodice VARCHAR(16), SettoreDescr VARCHAR(128), LettoCodice VARCHAR(16)
		, RepartoDimissioneCodice VARCHAR(16), RepartoDimissioneDescr VARCHAR(128)
		) 

	DECLARE @PazientiTable TABLE (
		Id UNIQUEIDENTIFIER,Nome VARCHAR(64),Cognome VARCHAR(64)
		,CodiceFiscale VARCHAR(16),DataNascita DATETIME, LuogoNascitaCodice VARCHAR(6), LuogoNascitaDescrizione VARCHAR(128), Sesso VARCHAR(1)
		, CodiceSanitario VARCHAR(16)
		, DomicilioComuneCodice VARCHAR(6), DomicilioComuneDescrizione VARCHAR(128)
		, DomicilioCap VARCHAR(8), DomicilioIndirizzo VARCHAR(256)
		, ConsensoAziendaleCodice TINYINT, ConsensoAziendaleDescrizione VARCHAR(64), ConsensoAziendaleData DATETIME
		, DataDecesso DATETIME
		)

    IF @ModalitaRicerca = 'Paziente'
	BEGIN
		SET @T1 = GETDATE()
		--
		-- Eseguo prima ricerca anagrafica
		--
		INSERT INTO @PazientiTable (Id, Nome, Cognome, CodiceFiscale, DataNascita)
		SELECT Id, UPPER(Nome), UPPER(Cognome), CodiceFiscale, DataNascita
		FROM [sac].[OttienePazientiPerGeneralita](30000, @Cognome, @Nome, @DataNascita, @AnnoNascita,@LuogoNascita , NULL)
										 
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
		, R.NumeroNosologico
		, R.DataAccettazione
		, R.DataTrasferimento
		, R.DataDimissione		
		, RepartoAccettazioneCodice
		, RepartoAccettazioneDescr
		, R.RepartoCorrenteCodice
		, R.RepartoCorrenteDescr 
		-- Stato del ricovero
		, R.StatoCodice		
		, R.StatoDescrizione
		, R.TipoRicoveroCodice
		, R.TipoRicoveroDescr
		, R.Categoria
		, NumeroNosologicoOrigine
		, SettoreCodice
		, SettoreDescr
		, LettoCodice 
		, RepartoDimissioneCodice
		, RepartoDimissioneDescr
	FROM
		ws3.Ricoveri AS R WITH(NOLOCK)
	WHERE
		--
		-- Filtro per UnitaOperativa e Oscuramenti
		--
		(
			(@ViewAll = 1) 
			OR 
			(
				EXISTS( SELECT * FROM dbo.OttieniUnitaOperativePerToken(@IdToken) AS Rep1
						WHERE   Rep1.UnitaOperativaAzienda = R.AziendaErogante AND Rep1.UnitaOperativaCodice = R.RepartoCodice)
				AND 
				([dbo].[CheckRicoveroOscuramenti](@IdRuolo, R.AziendaErogante, R.NumeroNosologico) = 1)
			)
		) 	
		AND EXISTS (SELECT * FROM @TabRicoveroStatiCodiceParam AS TAB WHERE TAB.Codice = R.StatoCodice)
		--
		-- Filtro per i reparti richiesti
		-- Sarebbe meglio nella JOIN ma serve gestire se NULL????
		AND ( 
			EXISTS (SELECT * FROM @RepartiRicovero AS TAB WHERE TAB.Azienda = R.AziendaErogante 
						AND TAB.Codice= R.RepartoCodice ) 
				OR	NOT EXISTS (SELECT * FROM @RepartiRicovero)
			)

		--Eventuale filtro sul nosologico
		AND (
			(R.AziendaErogante = @AziendaEroganteNosologico OR @AziendaEroganteNosologico IS NULL)
			AND 
			(R.NumeroNosologico = @NumeroNosologico OR @NumeroNosologico IS NULL)
			)

		AND (R.TipoRicoveroCodice = @TipoRicoveroCodice)
		AND R.IdPaziente <> '00000000-0000-0000-0000-000000000000'
		AND (R.DataPartizione >= @DataPartizioneDal)
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
				(@StatoRicovero=3 AND R.StatoCodice IN (20,21,23) --Prenotazioni	IN ATTESA/CHIAMATO/SOSPESA
					AND (
								(
									(@DataAccettazioneDal <= R.DataAccettazione OR @DataAccettazioneDal IS NULL)
									AND (@DataAccettazioneAl >= R.DataAccettazione OR @DataAccettazioneAl IS NULL)	
								 ) 
						)
				)
			)
	)
	
	INSERT INTO @TempRicoveri (
		  IdPaziente, IdPazienteAttivo
		, IdRicovero
		, AziendaErogante
		, NumeroNosologico
		, DataAccettazione , DataTrasferimento, DataDimissione 
		, RepartoAccettazioneCodice, RepartoAccettazioneDescr
		, RepartoCorrenteCodice, RepartoCorrenteDescr
		, StatoCodice, StatoDescrizione
		, TipoRicoveroCodice , TipoRicoveroDescr
		, Categoria
		, NumeroNosologicoOrigine
		, SettoreCodice , SettoreDescr , LettoCodice 
		, RepartoDimissioneCodice, RepartoDimissioneDescr
		) 
	   --MODIFICA SANDRO 2017-06-28: SQL non valuta @PazientiTable, il patter con OR non si può usare
       SELECT TOP(@MaxNumRow) *
             FROM RicoveriSp R
             WHERE @ModalitaRicerca = 'Paziente'
                    AND EXISTS (SELECT * FROM @PazientiTable P WHERE P.Id = R.IdPaziente)
       UNION ALL
       SELECT TOP(@MaxNumRow) R.*
             FROM RicoveriSp R INNER JOIN [sac].[Pazienti] P
				ON R.IdPaziente = P.Id

             WHERE @ModalitaRicerca = 'RicoveriPaziente'
				AND Cognome LIKE @Cognome + '%'
				AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
				AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
				AND (LuogoNascitaDescrizione = @LuogoNascita OR @LuogoNascita IS NULL)
				AND (DataNascita BETWEEN @DataNascitaMin AND @DataNascitaMax OR @AnnoNascita IS NULL)

       UNION ALL
       SELECT TOP(@MaxNumRow) *
             FROM RicoveriSp R
             WHERE @ModalitaRicerca = 'Ricoveri'
    ORDER BY R.DataAccettazione DESC
    OPTION (RECOMPILE)
	

	PRINT 'Ricerca sui ricoveri: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'
	--
	-- Completo i dati del paziente con le info del paziente ATTIVO della fusione
	-- Integro e inserisco a seconda del la modalità di ricerca
	--
	IF  @ModalitaRicerca <> 'Paziente'
	BEGIN
		SET @T1 = GETDATE()		

		INSERT INTO @PazientiTable(Id, Nome, Cognome, CodiceFiscale, DataNascita, LuogoNascitaCodice, LuogoNascitaDescrizione, Sesso
			, DomicilioComuneCodice, DomicilioComuneDescrizione, DomicilioCap, DomicilioIndirizzo
			, ConsensoAziendaleCodice , ConsensoAziendaleDescrizione, ConsensoAziendaleData, DataDecesso)
		SELECT DISTINCT Id, UPPER(Nome), UPPER(Cognome), CodiceFiscale, DataNascita, LuogoNascitaCodice, LuogoNascitaDescrizione, Sesso
			, DomicilioComuneCodice, DomicilioComuneDescrizione, DomicilioCap, DomicilioIndirizzo
			, ConsensoAziendaleCodice, ConsensoAziendaleDescrizione, ConsensoAziendaleData, DataDecesso					

		FROM @TempRicoveri AS TEMP
			CROSS APPLY sac.OttienePazientePerIdSac(TEMP.IdPazienteAttivo) AS P			
			
		PRINT 'Ricerca dati paziente: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'			
	END ELSE BEGIN
	
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
			@TempRicoveri AS Ric	--la join con @TempRicoveri limita le chiamate alla sac.OttienePazientePerIdSac()
			INNER JOIN @PazientiTable AS TEMP
				ON Ric.IdPazienteAttivo = TEMP.Id
			OUTER APPLY sac.OttienePazientePerIdSac(TEMP.Id) AS P			
			
		PRINT 'Integra dati paziente: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'			
	END
	--
	-- Ora eseguo select per restituire i dati e popolare la parte anagrafica del paziente + consenso
	--
	SET @T1 = GETDATE()	
	SELECT 
		P.Id 
		, P.Cognome
		, P.Nome
		, P.CodiceFiscale
		, P.DataNascita
		, P.Sesso		
		, P.LuogoNascitaCodice
		, P.LuogoNascitaDescrizione
		, P.CodiceSanitario
		, P.DomicilioComuneCodice AS ComuneDomicilioCodice
		, P.DomicilioComuneDescrizione AS ComuneDomicilioDescrizione
		, P.DomicilioCap AS ComuneDomicilioCap
		, P.DomicilioIndirizzo AS IndirizzoDomicilio
		, P.DataDecesso
		--Dati del consenso aziendale: --NULL, 1=Generico, 2=Dossier, 3=DossierStorico
		, ConsensoAziendaleCodice
		, ConsensoAziendaleDescrizione
		, ConsensoAziendaleData			
		--
		-- Prendo i dati di AnteprimaReferti e li scrivo in campi strutturati
		--
		,AR.NumeroReferti
		,AR.UltimoRefertoSistemaErogante
		,AR.UltimoRefertoData
		--
		-- Informazioni di ricovero
		--
		, Ric.Categoria AS EpisodioCategoria
		, Ric.NumeroNosologicoOrigine AS EpisodioNumeroNosologicoOrigine
		, Ric.TipoRicoveroCodice AS EpisodioTipoCodice
		, Ric.TipoRicoveroDescr AS EpisodioTipoDescrizione
		--Stato del ricovero corrente (Dimesso, Ricoverato, Trasferito, In Prenotazione)				
		, Ric.StatoCodice AS EpisodioStatoCodice
		, Ric.StatoDescrizione AS EpisodioStatoDescrizione
		, Ric.AziendaErogante  AS EpisodioAziendaErogante
		, Ric.NumeroNosologico  AS EpisodioNumeroNosologico
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
		, Ric.SettoreDescr  AS EpisodioSettoreDescrizione
		, Ric.LettoCodice AS EpisodioLettoCodice
		--
		-- Restituisco i dati di anteprima per le note anamnestiche
		--
		, PA.NumeroNoteAnamnestiche
		, PA.UltimaNotaAnamnesticaData
		, PA.UltimaNotaAnamnesticaSistemaEroganteDescr

	FROM 
		@TempRicoveri AS Ric
		INNER JOIN @PazientiTable AS P
			ON Ric.IdPazienteAttivo = P.Id
		LEFT OUTER JOIN dbo.PazientiAnteprima AS PA
			ON PA.IdPaziente = P.Id
		OUTER APPLY dbo.ParseAnteprimaReferti(PA.AnteprimaReferti) AS AR
		
	ORDER BY 
	--Default 
	CASE @Ordinamento WHEN '' THEN P.Cognome END DESC
	, CASE @Ordinamento WHEN '' THEN P.Nome END DESC
	--Ascendente
	, CASE @Ordinamento WHEN 'Id@ASC' THEN P.Id END ASC
	, CASE @Ordinamento WHEN 'Cognome@ASC' THEN P.Cognome END ASC
	, CASE @Ordinamento WHEN 'Nome@ASC' THEN P.Nome END ASC	
	, CASE @Ordinamento WHEN 'CodiceFiscale@ASC' THEN P.CodiceFiscale END ASC
	, CASE @Ordinamento WHEN 'DataNascita@ASC' THEN P.DataNascita END ASC
	, CASE @Ordinamento WHEN 'Sesso@ASC' THEN P.Sesso END ASC		
	, CASE @Ordinamento WHEN 'LuogoNascitaCodice@ASC' THEN P.LuogoNascitaCodice END ASC
	, CASE @Ordinamento WHEN 'LuogoNascitaDescrizione@ASC' THEN P.LuogoNascitaDescrizione END ASC	
	, CASE @Ordinamento WHEN 'CodiceSanitario@ASC' THEN P.CodiceSanitario END ASC
	, CASE @Ordinamento WHEN 'ComuneDomicilioCodice@ASC' THEN P.DomicilioComuneCodice END ASC
	, CASE @Ordinamento WHEN 'ComuneDomicilioDescrizione@ASC' THEN P.DomicilioComuneDescrizione END ASC	
	, CASE @Ordinamento WHEN 'ComuneDomicilioCap@ASC' THEN P.DomicilioCap END ASC	
	, CASE @Ordinamento WHEN 'IndirizzoDomicilio@ASC' THEN P.DomicilioIndirizzo END ASC	
	, CASE @Ordinamento WHEN 'DataDecesso@ASC' THEN P.DataDecesso END ASC	
	, CASE @Ordinamento WHEN 'ConsensoAziendaleCodice@ASC' THEN P.ConsensoAziendaleCodice END ASC
	, CASE @Ordinamento WHEN 'ConsensoAziendaleDescrizione@ASC' THEN P.ConsensoAziendaleDescrizione END ASC
	, CASE @Ordinamento WHEN 'ConsensoAziendaleData@ASC' THEN P.ConsensoAziendaleData END ASC
	, CASE @Ordinamento WHEN 'NumeroReferti@ASC' THEN AR.NumeroReferti END ASC
	, CASE @Ordinamento WHEN 'UltimoRefertoSistemaErogante@ASC' THEN AR.UltimoRefertoSistemaErogante END ASC
    , CASE @Ordinamento WHEN 'UltimoRefertoData@ASC' THEN AR.UltimoRefertoData END ASC
    , CASE @Ordinamento WHEN 'EpisodioCategoria@ASC' THEN Ric.Categoria END ASC		        
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologicoOrigine@ASC' THEN Ric.NumeroNosologicoOrigine END ASC
	, CASE @Ordinamento WHEN 'EpisodioTipoCodice@ASC' THEN Ric.TipoRicoveroCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioTipoDescrizione@ASC' THEN Ric.TipoRicoveroDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioStatoCodice@ASC' THEN Ric.StatoCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStatoDescrizione@ASC' THEN Ric.StatoDescrizione END ASC
	, CASE @Ordinamento WHEN 'EpisodioAziendaErogante@ASC' THEN Ric.AziendaErogante END ASC
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologico@ASC' THEN Ric.NumeroNosologico END ASC
	, CASE @Ordinamento WHEN 'EpisodioDataApertura@ASC' THEN Ric.DataAccettazione END ASC
	, CASE @Ordinamento WHEN 'EpisodioDataUltimoEvento@ASC' THEN Ric.DataTrasferimento END ASC
	, CASE @Ordinamento WHEN 'EpisodioDataConclusione@ASC' THEN Ric.DataDimissione END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaCodice@ASC' THEN Ric.RepartoAccettazioneCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaDescrizione@ASC' THEN Ric.RepartoAccettazioneDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoCodice@ASC' THEN Ric.RepartoCorrenteCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoDescrizione@ASC' THEN Ric.RepartoCorrenteDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneCodice@ASC' THEN Ric.RepartoDimissioneCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneDescrizione@ASC' THEN Ric.RepartoDimissioneDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioSettoreCodice@ASC' THEN Ric.SettoreCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioSettoreDescrizione@ASC' THEN Ric.SettoreDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioLettoCodice@ASC' THEN Ric.LettoCodice END ASC
    , CASE @Ordinamento  WHEN 'NumeroNoteAnamnestiche@ASC' THEN PA.NumeroNoteAnamnestiche END ASC   
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaData@ASC' THEN PA.UltimaNotaAnamnesticaData END ASC   
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaSistemaEroganteDescr@ASC' THEN PA.UltimaNotaAnamnesticaSistemaEroganteDescr END ASC   
	--Discendente
	, CASE @Ordinamento WHEN 'Id@DESC' THEN P.Id END DESC
	, CASE @Ordinamento WHEN 'Cognome@DESC' THEN P.Cognome END DESC
	, CASE @Ordinamento WHEN 'Nome@DESC' THEN P.Nome END DESC	
	, CASE @Ordinamento WHEN 'CodiceFiscale@DESC' THEN P.CodiceFiscale END DESC
	, CASE @Ordinamento WHEN 'DataNascita@DESC' THEN P.DataNascita END DESC
	, CASE @Ordinamento WHEN 'Sesso@DESC' THEN P.Sesso END DESC		
	, CASE @Ordinamento WHEN 'LuogoNascitaCodice@DESC' THEN P.LuogoNascitaCodice END DESC
	, CASE @Ordinamento WHEN 'LuogoNascitaDescrizione@DESC' THEN P.LuogoNascitaDescrizione END DESC	
	, CASE @Ordinamento WHEN 'CodiceSanitario@DESC' THEN P.CodiceSanitario END DESC
	, CASE @Ordinamento WHEN 'ComuneDomicilioCodice@DESC' THEN P.DomicilioComuneCodice END DESC
	, CASE @Ordinamento WHEN 'ComuneDomicilioDescrizione@DESC' THEN P.DomicilioComuneDescrizione END DESC	
	, CASE @Ordinamento WHEN 'ComuneDomicilioCap@DESC' THEN P.DomicilioCap END DESC	
	, CASE @Ordinamento WHEN 'IndirizzoDomicilio@DESC' THEN P.DomicilioIndirizzo END DESC	
	, CASE @Ordinamento WHEN 'DataDecesso@DESC' THEN P.DataDecesso END DESC	
	, CASE @Ordinamento WHEN 'ConsensoAziendaleCodice@DESC' THEN P.ConsensoAziendaleCodice END DESC
	, CASE @Ordinamento WHEN 'ConsensoAziendaleDescrizione@DESC' THEN P.ConsensoAziendaleDescrizione END DESC
	, CASE @Ordinamento WHEN 'ConsensoAziendaleData@DESC' THEN P.ConsensoAziendaleData END DESC
	, CASE @Ordinamento WHEN 'NumeroReferti@DESC' THEN AR.NumeroReferti END DESC
	, CASE @Ordinamento WHEN 'UltimoRefertoSistemaErogante@DESC' THEN AR.UltimoRefertoSistemaErogante END DESC
    , CASE @Ordinamento WHEN 'UltimoRefertoData@DESC' THEN AR.UltimoRefertoData END DESC
	, CASE @Ordinamento WHEN 'EpisodioCategoria@DESC' THEN Ric.Categoria END DESC
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologicoOrigine@DESC' THEN Ric.NumeroNosologicoOrigine END DESC
	, CASE @Ordinamento WHEN 'EpisodioTipoCodice@DESC' THEN Ric.TipoRicoveroCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioTipoDescrizione@DESC' THEN Ric.TipoRicoveroDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioStatoCodice@DESC' THEN Ric.StatoCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStatoDescrizione@DESC' THEN Ric.StatoDescrizione END DESC
	, CASE @Ordinamento WHEN 'EpisodioAziendaErogante@DESC' THEN Ric.AziendaErogante END DESC
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologico@DESC' THEN Ric.NumeroNosologico END DESC
	, CASE @Ordinamento WHEN 'EpisodioDataApertura@DESC' THEN Ric.DataAccettazione END DESC
	, CASE @Ordinamento WHEN 'EpisodioDataUltimoEvento@DESC' THEN Ric.DataTrasferimento END DESC
	, CASE @Ordinamento WHEN 'EpisodioDataConclusione@DESC' THEN Ric.DataDimissione END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaCodice@DESC' THEN Ric.RepartoAccettazioneCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaDescrizione@DESC' THEN Ric.RepartoAccettazioneDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoCodice@DESC' THEN Ric.RepartoCorrenteCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoDescrizione@DESC' THEN Ric.RepartoCorrenteDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneCodice@DESC' THEN Ric.RepartoDimissioneCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneDescrizione@DESC' THEN Ric.RepartoDimissioneDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioSettoreCodice@DESC' THEN Ric.SettoreCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioSettoreDescrizione@DESC' THEN Ric.SettoreDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioLettoCodice@DESC' THEN Ric.LettoCodice END DESC
    , CASE @Ordinamento  WHEN 'NumeroNoteAnamnestiche@DESC' THEN PA.NumeroNoteAnamnestiche END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaData@DESC' THEN PA.UltimaNotaAnamnesticaData END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaSistemaEroganteDescr@DESC' THEN PA.UltimaNotaAnamnesticaSistemaEroganteDescr END DESC
	-- Per SQL 2014
	OPTION(RECOMPILE)

	PRINT 'Restituzione dati: ' + CAST(DATEDIFF(ms, @T1, GETDATE()) AS VARCHAR(10)) + ' millisecondi'		
	PRINT 'Durata totale della query: ' + CAST(DATEDIFF(ms, @T0, GETDATE()) AS VARCHAR(10)) + ' millisecondi'
END