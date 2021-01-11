







-- =============================================
-- Author:		SimoneB
-- Create date: 2019-06-06
-- Description:	Restituisce elenco dei pazienti prenotati.
-- Modify date: 2019-10-09 - ETTORE: Eliminazione parametro @StatoRicovero
--									  Ricerca dei codici di urgenza negli eventi di tipo IL e ML
--									  Uso dell'attributo "Categoria" al posto di "Urgenza" per trovare i codici di urgenza
-- Modify date: 2019-10-29 - ETTORE: Modificata obbliogatorietà dei parametri: se c'è codice fiscale non obbligatorie tre lettere del cognome
--									  
-- ATTENZIONE: 
--		Per tale metodo, che è un metodo specifico che restituisce un sottoinsieme degli stati delle liste di attesa, 
--		per il quale serve un dettaglio specifico nella descrizione dello stato della prenotazione (campo "EpisodioStatoDescrizione")
--		si è scelto di rimappare sul campo "EpisodioStatoDescrizione" la descrizione dettagliata degli stati.
-- =============================================
CREATE PROCEDURE [ws3].[PazientiPrenotatiByReparti]
(
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER
	, @Ordinamento		VARCHAR(128)
	, @RepartiRicovero	AS RepartiRicovero READONLY
	, @TipoRicoveroCodice VARCHAR(16)
	, @DataDal			DATETIME = NULL
	, @DataAl			DATETIME = NULL
	, @Cognome			VARCHAR(64)=NULL
	, @Nome				VARCHAR(64)	= NULL
	, @CodiceFiscale	VARCHAR(16) = NULL
	, @DataNascita		DATETIME = NULL
	, @AnnoNascita		INT = NULL
	, @LuogoNascita		VARCHAR(80)=NULL
) WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @T0 DATETIME2 = SYSDATETIME() --per durata totale
	DECLARE @T1 DATETIME2 --per durata dei singoli step
	DECLARE @ViewAll  BIT = 0 
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	DECLARE @DataPartizioneDal DATETIME
	DECLARE @RepartiRicoveroVuota AS BIT=0

	--TEMP TABLE
	DECLARE @TabRicoveroStatiCodiceParam AS TABLE (Codice VARCHAR(16))
	DECLARE @FiltroReparti AS TABLE (Azienda VARCHAR(16), Codice VARCHAR(64)) --contiene tutte le unità operative utilizzabili dal ruolo associato al token

	--
	-- Limitazioni e valori di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento ,'')
	IF @MaxNumRow > 1000 SET @MaxNumRow = 1000
	IF @DataDal IS NULL SET @DataDal = DATEADD(year, -10, GETDATE())
	IF @DataAl IS NULL	SET @DataAl = GETDATE()

	IF LTRIM(RTRIM(@Cognome)) = '' SET @Cognome = NULL
	IF LTRIM(RTRIM(@Nome)) = '' SET @Nome = NULL
	IF LTRIM(RTRIM(@CodiceFiscale)) = '' SET @CodiceFiscale = NULL
	IF LTRIM(RTRIM(@LuogoNascita)) = '' SET @LuogoNascita = NULL
	IF LTRIM(RTRIM(@TipoRicoveroCodice)) = '' SET @TipoRicoveroCodice = NULL

	--
	-- Controllo obbligatorietà
	--
	IF LEN(ISNULL(@Cognome,'')) < 3 AND LEN(ISNULL(@CodiceFiscale,'')) = 0 
	BEGIN
		RAISERROR('Valorizzare il parametro @CodiceFiscale oppure il parametro @Cognome con almeno tre caratteri.', 16, 1)
		RETURN
	END


	-- 
	-- Popolazione della tabella di filtro degli stati del ricovero
	-- 20=InAttesa, 21=Chiamato, 23=Sospeso
	--
	INSERT INTO @TabRicoveroStatiCodiceParam (Codice) VALUES (20),(21),(23)

	--
	-- VERIFICO SE L'UTENTE PUO' VISUALIZZARE TUTTO
	--
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
	PRINT '@ViewAll:' + CAST(@ViewAll AS VARCHAR(10))

	--
	-- Ricavo IdRuolo associato al token
	--
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	PRINT ' @IdRuolo :' + CAST( @IdRuolo  AS VARCHAR(40))

	--
	-- Valorizzo la data di partizione
	--
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DataDal)	
	--
	-- POPOLAZIONE DELLA TABELLA @FiltroReparti 
	-- SE il parametro @RepartiRicovero E' VUOTO ALLORA UTILIZZO I REPARTI CONTENUTI IN dbo.OttieniUnitaOperativePerToken(@IdToken)
	-- ALTRIMENTI ELIMINO DA @RepartiRicovero TUTTI I REPARTI CHE NON SONO TRA LE UNITA' OPERATIVE DEL TOKEN.
	--
	IF NOT EXISTS(SELECT * FROM @RepartiRicovero )
	BEGIN
		INSERT INTO @FiltroReparti
		SELECT UnitaOperativaAzienda AS Azienda, UnitaOperativaCodice AS Codice FROM dbo.OttieniUnitaOperativePerToken(@IdToken)
	END 
	ELSE
	BEGIN
		INSERT INTO @FiltroReparti
		SELECT RR.Azienda,RR.Codice
		FROM @RepartiRicovero as RR
			INNER JOIN dbo.OttieniUnitaOperativePerToken(@IdToken) AS UO
			ON RR.Azienda = UO.UnitaOperativaAzienda
					AND RR.Codice = UO.UnitaOperativaCodice
	END


	--
	-- Calcolo la tabella dei ricoveri già filtrata per paziente, unità operative del token, reparti passati come parametro e per gli stati del ricovero
	--
	SET @T1 = SYSDATETIME()	
	;WITH FiltroRicoveri AS	
	(
	SELECT TOP (@MaxNumRow )
		dbo.GetPazienteAttivoByIdSac(RB.IdPaziente) AS IdPaziente 
		,RB.Id AS IdRicovero
	FROM store.RicoveriBase AS RB WITH(NOLOCK)
		INNER JOIN [sac].[Pazienti] AS P --Questa restituisce sia gli ATTIVI che i FUSI
			ON RB.IdPAziente = P.Id
	WHERE
		--filtri su Ricoveri
		(RB.TipoRicoveroCodice = @TipoRicoveroCodice OR @TipoRicoveroCodice IS NULL)
		AND (RB.DataPartizione >= @DataPartizioneDal)
		AND RB.IdPaziente <> '00000000-0000-0000-0000-000000000000'
		AND RB.DataAccettazione between @DataDal AND @DataAl
		--filtri su Paziente
		AND (P.Cognome like @Cognome + '%' OR @Cognome IS NULL)
		AND (P.Nome like @Nome + '%' OR @NOme IS NULL)
		AND (P.CodiceFiscale = @CodiceFiscale OR @CodiceFiscale IS NULL)
		AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
		AND (LuogoNascitaDescrizione = @LuogoNascita OR @LuogoNascita IS NULL)
		AND (YEAR(DataNascita) = @AnnoNascita OR @AnnoNascita IS NULL)

		--filtro sugli stati del ricovero
		AND EXISTS (SELECT * FROM @TabRicoveroStatiCodiceParam AS filtroStatiCodice
							WHERE filtroStatiCodice.Codice= Rb.[StatoCodice] ) 

		--FILTRO SUI REPARTI DI RICOVERO PASSATI NEL PARAMETRO
		AND (@ViewAll = 1 OR EXISTS (SELECT * FROM @FiltroReparti AS filtroReparto
							WHERE filtroReparto.Azienda = RB.AziendaErogante 
							AND filtroReparto.Codice= RB.RepartoCodice ) 
			)
	ORDER BY RB.DataAccettazione DESC
	)
	
	--
	-- Il TOP è nella parte della query che esegue "FiltroRicoveri".
	-- Problema da risolvere è che i record tornati potrebbero essere meno del TOP
	-- Il WS potrebbe richiamare la stessa SP se implementassimo pa PAGINAZIONE
	--
	-- Filtro su oscuramenti e ricavo altri dati di anteprima
	--
	SELECT
		--
		-- Dati Paziente
		--
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
		, P.ConsensoAziendaleCodice
		, P.ConsensoAziendaleDescrizione
		, P.ConsensoAziendaleData			
		--Anteprima referti
		, AR.NumeroReferti
		, AR.UltimoRefertoSistemaErogante
		, AR.UltimoRefertoData
		--
		-- Dati del ricovero
		--
		, R.Categoria AS EpisodioCategoria
		, R.NumeroNosologicoOrigine AS EpisodioNumeroNosologicoOrigine
		, R.TipoRicoveroCodice AS EpisodioTipoCodice
		, R.TipoRicoveroDescr AS EpisodioTipoDescrizione
		--
		-- Stato della PRENOTAZIONE corrente
		-- Il metodo tratta solo gli stati 20=InAttesa, 21=Chiamato, 23=Sospeso (vedi tabella temporanea "@TabRicoveroStatiCodiceParam")
		--
		, R.StatoCodice AS EpisodioStatoCodice
		--
		-- Rimappatura della descrizione sul singolo stato
		--, R.StatoDescrizione AS EpisodioStatoDescrizione --Contiene la descrizione macro dello stato
		--
		, RS.Descrizione AS EpisodioStatoDescrizione	--Contiene la descrizione specifica dello stato
		, R.AziendaErogante  AS EpisodioAziendaErogante
		, R.NumeroNosologico  AS EpisodioNumeroNosologico
		, R.DataAccettazione AS EpisodioDataApertura
		, R.DataTrasferimento AS EpisodioDataUltimoEvento
		, R.DataDimissione AS EpisodioDataConclusione
		, R.RepartoAccettazioneCodice AS EpisodioStrutturaAperturaCodice
		, R.RepartoAccettazioneDescr AS EpisodioStrutturaAperturaDescrizione
		, R.RepartoCorrenteCodice AS EpisodioStrutturaUltimoEventoCodice
		, R.RepartoCorrenteDescr AS EpisodioStrutturaUltimoEventoDescrizione
		, R.RepartoDimissioneCodice AS EpisodioStrutturaConclusioneCodice
		, R.RepartoDimissioneDescr AS EpisodioStrutturaConclusioneDescrizione
		, R.SettoreCodice AS EpisodioSettoreCodice
		, R.SettoreDescr  AS EpisodioSettoreDescrizione
		, R.LettoCodice AS EpisodioLettoCodice
		--Anteprima NoteAnamnestiche
		, PA.NumeroNoteAnamnestiche
		, PA.UltimaNotaAnamnesticaData
		, PA.UltimaNotaAnamnesticaSistemaEroganteDescr
		--
		-- RESTITUZIONE DI URGENZA CODICE
		--
		,EV.UrgenzaCodice
		,CASE 
			WHEN EV.UrgenzaCodice = 'A' THEN		CAST('A' AS VARCHAR(128)) 
			WHEN EV.UrgenzaCodice = 'B' THEN		CAST('B' AS VARCHAR(128))
			WHEN EV.UrgenzaCodice = 'C' THEN		CAST('C' AS VARCHAR(128)) 
			WHEN EV.UrgenzaCodice = 'D' THEN		CAST('D' AS VARCHAR(128))
			ELSE									CAST(EV.UrgenzaCodice AS VARCHAR(128))
			END AS UrgenzaDescrizione

	FROM ws3.Ricoveri AS R
		--
		-- Eseguo join per ricavare descrizione specifica dello stato della prenotazione
		--
		INNER JOIN dbo.RicoveriStati AS RS
			ON RS.Id = R.StatoCodice
		--
		-- La RIGHT join ci consenti di tornare tutti i record trovati
		-- per sapere se abbiamo raggiunto il TOP
		-- Il WCF deve ecludere i record con nosologico NULL, perche' significa che sono OSCURATI PUNTUALMENTE
		--
		RIGHT JOIN FiltroRicoveri AS TAB
			ON TAB.IdRicovero = R.Id
		--
		-- Facendo una LEFT questa equivale ad un look up e siamo sicuri che viene eseguta dopo  la prima join di filtro
		--
		LEFT OUTER JOIN [sac].[Pazienti] AS P --Questa ha sia gli ATTIVI che i FUSI
						ON TAB.IdPAziente = P.Id

		LEFT OUTER JOIN dbo.PazientiAnteprima AS PA
			ON PA.IdPaziente = TAB.IdPaziente

		OUTER APPLY dbo.ParseAnteprimaReferti(PA.AnteprimaReferti) AS AR

		--Eseguo un look up per ottenere il codice di urgenza
		OUTER APPLY (SELECT TOP 1 CONVERT(VARCHAR(16), dbo.GetEventiAttributo( EA.Id, 'Categoria')) AS UrgenzaCodice
						FROM store.EventiBase AS EA
						WHERE EA.AziendaERogante=R.AziendaErogante 
							AND EA.NumeroNosologico = R.NumeroNosologico
							AND EA.TipoEventoCodice IN ('IL', 'ML')
							AND EA.DataPartizione >= @DataPartizioneDal
						ORDER BY EA.[DataEvento] DESC
					) EV

	WHERE 
		(@ViewAll = 1) 
		OR 
		(
			([dbo].[CheckRicoveroOscuramenti](@IdRuolo, R.AziendaErogante, R.NumeroNosologico) = 1)
		)

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
    , CASE @Ordinamento WHEN 'EpisodioCategoria@ASC' THEN R.Categoria END ASC		        
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologicoOrigine@ASC' THEN R.NumeroNosologicoOrigine END ASC
	, CASE @Ordinamento WHEN 'EpisodioTipoCodice@ASC' THEN R.TipoRicoveroCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioTipoDescrizione@ASC' THEN R.TipoRicoveroDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioStatoCodice@ASC' THEN R.StatoCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStatoDescrizione@ASC' THEN R.StatoDescrizione END ASC
	, CASE @Ordinamento WHEN 'EpisodioAziendaErogante@ASC' THEN R.AziendaErogante END ASC
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologico@ASC' THEN R.NumeroNosologico END ASC
	, CASE @Ordinamento WHEN 'EpisodioDataApertura@ASC' THEN R.DataAccettazione END ASC
	, CASE @Ordinamento WHEN 'EpisodioDataUltimoEvento@ASC' THEN R.DataTrasferimento END ASC
	, CASE @Ordinamento WHEN 'EpisodioDataConclusione@ASC' THEN R.DataDimissione END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaCodice@ASC' THEN R.RepartoAccettazioneCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaDescrizione@ASC' THEN R.RepartoAccettazioneDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoCodice@ASC' THEN R.RepartoCorrenteCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoDescrizione@ASC' THEN R.RepartoCorrenteDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneCodice@ASC' THEN R.RepartoDimissioneCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneDescrizione@ASC' THEN R.RepartoDimissioneDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioSettoreCodice@ASC' THEN R.SettoreCodice END ASC
	, CASE @Ordinamento WHEN 'EpisodioSettoreDescrizione@ASC' THEN R.SettoreDescr END ASC
	, CASE @Ordinamento WHEN 'EpisodioLettoCodice@ASC' THEN R.LettoCodice END ASC
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
	, CASE @Ordinamento WHEN 'EpisodioCategoria@DESC' THEN R.Categoria END DESC
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologicoOrigine@DESC' THEN R.NumeroNosologicoOrigine END DESC
	, CASE @Ordinamento WHEN 'EpisodioTipoCodice@DESC' THEN R.TipoRicoveroCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioTipoDescrizione@DESC' THEN R.TipoRicoveroDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioStatoCodice@DESC' THEN R.StatoCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStatoDescrizione@DESC' THEN R.StatoDescrizione END DESC
	, CASE @Ordinamento WHEN 'EpisodioAziendaErogante@DESC' THEN R.AziendaErogante END DESC
	, CASE @Ordinamento WHEN 'EpisodioNumeroNosologico@DESC' THEN R.NumeroNosologico END DESC
	, CASE @Ordinamento WHEN 'EpisodioDataApertura@DESC' THEN R.DataAccettazione END DESC
	, CASE @Ordinamento WHEN 'EpisodioDataUltimoEvento@DESC' THEN R.DataTrasferimento END DESC
	, CASE @Ordinamento WHEN 'EpisodioDataConclusione@DESC' THEN R.DataDimissione END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaCodice@DESC' THEN R.RepartoAccettazioneCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaAperturaDescrizione@DESC' THEN R.RepartoAccettazioneDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoCodice@DESC' THEN R.RepartoCorrenteCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaUltimoEventoDescrizione@DESC' THEN R.RepartoCorrenteDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneCodice@DESC' THEN R.RepartoDimissioneCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioStrutturaConclusioneDescrizione@DESC' THEN R.RepartoDimissioneDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioSettoreCodice@DESC' THEN R.SettoreCodice END DESC
	, CASE @Ordinamento WHEN 'EpisodioSettoreDescrizione@DESC' THEN R.SettoreDescr END DESC
	, CASE @Ordinamento WHEN 'EpisodioLettoCodice@DESC' THEN R.LettoCodice END DESC
    , CASE @Ordinamento  WHEN 'NumeroNoteAnamnestiche@DESC' THEN PA.NumeroNoteAnamnestiche END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaData@DESC' THEN PA.UltimaNotaAnamnesticaData END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaSistemaEroganteDescr@DESC' THEN PA.UltimaNotaAnamnesticaSistemaEroganteDescr END DESC
	OPTION(RECOMPILE)

	PRINT 'Restituzione dati: ' + CAST(DATEDIFF(ms, @T1, SYSDATETIME()) AS VARCHAR(10)) + ' ms '

	PRINT 'Durata totale: ' + CAST(DATEDIFF(ms, @T0, SYSDATETIME()) AS VARCHAR(10)) + ' ms '

END