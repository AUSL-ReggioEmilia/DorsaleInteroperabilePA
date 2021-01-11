

-- =============================================
-- Author:		Simone Bitti
-- Create date: 2019-06-12
-- Description:	Procedura che restituisce tutti i pazienti dimessi o ricoverati che sono transitati per un certo reparto e che hanno l'attributo SdoMadre.
-- =============================================
CREATE PROCEDURE [ws3].[PazientiNatiByReparti]
	
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER
	, @Ordinamento		VARCHAR(128)
	, @RepartiRicovero	AS RepartiRicovero READONLY
	, @StatoRicovero	TINYINT = NULL --0 = DIMESSO, 1= RICOVERATO, 2 = DIMESSO + RICOVERATO
	, @DataDal			DATETIME = NULL
	, @DataAl			DATETIME = NULL
	, @Cognome			VARCHAR(64)=NULL
	, @Nome				VARCHAR(64)	= NULL
	, @CodiceFiscale	VARCHAR(16) = NULL
	, @DataNascita		DATETIME = NULL
	, @AnnoNascita		INT = NULL
	, @LuogoNascita		VARCHAR(80)=NULL
	, @FiltroMadre		BIT = NULL

AS
BEGIN
	
	SET NOCOUNT ON;

	--VARIABILI INTERNE
	DECLARE @T0 DATETIME2 = SYSDATETIME() --PER DURATA TOTALE
	DECLARE @T1 DATETIME2 --PER DURATA DEI SINGOLI STEP
	DECLARE @ViewAll  BIT = 0
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	DECLARE @DataPartizioneRicoveriDal DATETIME

	--TEMP TABLE
	DECLARE @RicoveroStatiCodice AS TABLE (Codice VARCHAR(16))
	DECLARE @FiltroReparti AS TABLE (Azienda VARCHAR(16), Codice VARCHAR(64))

	-- CONTROLLI SUI PARAMETRI
	SET @Ordinamento = ISNULL(@Ordinamento ,'')
	IF @MaxNumRow > 1000 SET @MaxNumRow = 1000
	IF LTRIM(RTRIM(@Cognome)) = '' SET @Cognome = NULL
	IF LTRIM(RTRIM(@Nome)) = '' SET @Nome = NULL
	IF LTRIM(RTRIM(@CodiceFiscale)) = '' SET @CodiceFiscale = NULL
	IF LTRIM(RTRIM(@LuogoNascita)) = '' SET @LuogoNascita = NULL
	IF @DataDal IS NULL SET @DataDal = DATEADD(DAY, -30, GETDATE()) 
	IF @DataAl  IS NULL SET @DataAl = GETDATE()

	--
	-- Il metodo che chiama quasta SP imposta comunque @FiltroMadre = 0 o 1
	-- QUesta valorizzazione serve solo se si esegue direttamente la SP da consolle
	--
	IF @FiltroMadre IS NULL SET @FiltroMadre = 1
	PRINT '@FiltroMadre=' + CAST(@FiltroMadre AS VARCHAR(10))


	IF(@StatoRicovero = 0)
		BEGIN 
			INSERT INTO @RicoveroStatiCodice (Codice) VALUES (3) --DIMESSI
		END
	ELSE IF (@StatoRicovero = 1)
		BEGIN 
			INSERT INTO @RicoveroStatiCodice (Codice) VALUES (1),(2),(4) --RICOVERATI
		END
	ELSE
		BEGIN 
			INSERT INTO @RicoveroStatiCodice (Codice) VALUES (1),(2),(4),(3)--DIMESSI + RICOVERATI
		END 
		
	--
	-- Calcolo filtro per data partizione
	-- Se viene passata @DataDal la uso per ottenere IL filtro per data partizione ricoveri
	-- Altrimenti metto un default di -3 anni 
	-- Se @DataPartizioneRicoveriDal è NULL la fisso alla data minima possibile
	--
    SELECT @DataPartizioneRicoveriDal = dbo.OttieniFiltroRicoveriPerDataPartizione(@DataDal) 
	IF @DataPartizioneRicoveriDal IS NULL
	  SET @DataPartizioneRicoveriDal = DATEADD(YEAR, -3, GETDATE())

	-- CONTROLLO OBBLIGATORIETÀ
	PRINT 'Giorni:' + CAST(DATEDIFF(day, @DataDal, @DataAl) AS VARCHAR(10))
	IF DATEDIFF(day, @DataDal, @DataAl) > 60 AND LEN(ISNULL(@Cognome,'')) < 3 
	BEGIN
		RAISERROR('Il parametro @Cognome deve essere composto da almeno 3 caratteri se il range [DataDal,DataAl] è maggiore di 60 giorni.', 16, 1)
		RETURN
	END

	-- VERIFICO SE L'UTENTE PUO' VISUALIZZARE TUTTO
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
	PRINT '@ViewAll:' + CAST(@ViewAll AS VARCHAR(10))

	-- RICAVO L'ID DEL RUOLO ROLE MANAGER ASSOCIATO AL TOKEN
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	PRINT ' @IdRuolo :' + CAST( @IdRuolo  AS VARCHAR(40))

	-- SE @RepartiRicovero E' VUOTO ALLORA UTILIZZO I REPARTI CONTENUTI IN OttieniUnitaOperativePerToken
	-- ALTRIMENTI ELIMINO DA @RepartiRicovero TUTTI I REPARTI CHE NON SONO TRA LE UNITA' OPERATIVE DEL RUOLO.
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

	SET @T1 = SYSDATETIME()
	;WITH FiltroRicoveri AS
    (
		SELECT DISTINCT TOP (@MaxNumRow)
			  EB.AziendaErogante
			, EB.NumeroNosologico
			, EB.IdPaziente
			, RicB.DataAccettazione
			, RicAtt.Valore AS [SdoMadreNumeroNosologico]
		FROM
			store.eventibase AS EB

				--[sac].[Pazienti] HA SIA GLI ATTIVI CHE I FUSI
				INNER JOIN [sac].[Pazienti] AS P 
					ON EB.IdPAziente = P.Id

				INNER JOIN store.ricoveribase AS RicB
					ON RicB.AziendaErogante = EB.AziendaErogante 
						AND RicB.NumeroNOsologico = EB.NumeroNOsologico
						AND RicB.DataPartizione >= @DataPartizioneRicoveriDal

				LEFT JOIN store.RicoveriAttributi AS RicAtt
					ON RicAtt.IdRicoveriBase = RicB.Id
						AND RicAtt.DataPartizione = RicB.DataPartizione
						AND RicAtt.Nome = 'SdoMadreNumeroNosologico'

		WHERE
			--FILTRO SOLO PER I TRANSITATI
			(EB.TipoEventoCodice IN ('A','T'))
			AND (EB.StatoCodice = 0)
			AND (EB.TipoEpisodio = 'O') --solo ORDINARI
			AND (EB.DataPartizione >= @DataPartizioneRicoveriDal)
			AND (EB.DataEvento BETWEEN @DataDal AND @DataAl)
			--AND (
			--	(EB.DataEvento BETWEEN @DataDal AND @DataAl) --filtro su dataAccettazione (e DataTrasferimento per i T)
			--	OR 
			--	(RicB.DataDimissione BETWEEN @DataDal AND @DataAl) --filtro DataDimissione sui Ricoveri
			--)
			AND (RicAtt.IdRicoveriBase IS NOT NULL OR @FiltroMadre = 0)
			
			--FILTRO SUGLI STATI DEL RICOVERO
			AND EXISTS (SELECT * FROM @RicoveroStatiCodice AS filtroStatiCodice
								WHERE filtroStatiCodice.Codice= RicB.[StatoCodice] )

			--FILTRI SU PAZIENTE
			AND EB.IdPaziente <> '00000000-0000-0000-0000-000000000000'
			AND (P.Cognome like @Cognome + '%' OR @Cognome IS NULL)
			AND (P.Nome like @Nome + '%' OR @NOme IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (LuogoNascitaDescrizione = @LuogoNascita OR @LuogoNascita IS NULL)
			AND (YEAR(DataNascita) = @AnnoNascita OR @AnnoNascita IS NULL)

		
			--FILTRO SUI REPARTI DI RICOVERO PASSATI NEL PARAMETRO
			AND (EXISTS (SELECT * FROM @FiltroReparti AS filtroReparto
								WHERE filtroReparto.Azienda = EB.AziendaErogante 
								AND filtroReparto.Codice= EB.RepartoCodice ) 
					OR @ViewAll = 1
				)

		ORDER BY RicB.DataAccettazione DESC
	)
	
	
	SELECT
		-- DATI PAZIENTE
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
		
		--ANTEPRIMA REFERTI
		, AR.NumeroReferti
		, AR.UltimoRefertoSistemaErogante
		, AR.UltimoRefertoData
		
		
		-- DATI DEL RICOVERO
		, R.Categoria AS EpisodioCategoria
		, R.NumeroNosologicoOrigine AS EpisodioNumeroNosologicoOrigine
		, R.TipoRicoveroCodice AS EpisodioTipoCodice
		, R.TipoRicoveroDescr AS EpisodioTipoDescrizione
		
		--STATO DEL RICOVERO CORRENTE (DIMESSO, RICOVERATO, TRASFERITO, IN PRENOTAZIONE)				
		, R.StatoCodice AS EpisodioStatoCodice
		, R.StatoDescrizione AS EpisodioStatoDescrizione
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
		
		--ANTEPRIMA NOTEANAMNESTICHE
		, PA.NumeroNoteAnamnestiche
		, PA.UltimaNotaAnamnesticaData
		, PA.UltimaNotaAnamnesticaSistemaEroganteDescr

		--ATTRIBUTI SDOMADRE
		, CONVERT(VARCHAR(128),TAB.SdoMadreNumeroNosologico) AS SdoMadreNumeroNosologico --stesso nome dell'attributo
		, CONVERT(VARCHAR(128), dbo.GetRicoveriAttributo2( R.Id, R.DataPartizione,  'SdoMadreOspedaleCodice')) AS SdoMadreOspedaleCodice
		, CONVERT(VARCHAR(128), dbo.GetRicoveriAttributo2( R.Id, R.DataPartizione,  'SdoMadrePresidioCodice')) AS SdoMadrePresidioCodice
		, CONVERT(VARCHAR(128), dbo.GetRicoveriAttributo2( R.Id, R.DataPartizione,  'SdoMadreStabilimentoCodice')) AS SdoMadreStabilimentoCodice

	FROM ws3.Ricoveri AS R
		--
		-- LA RIGHT JOIN CI CONSENTI DI TORNARE TUTTI I RECORD TROVATI
		-- PER SAPERE SE ABBIAMO RAGGIUNTO IL TOP
		-- Il WCF deve ecludere i record con nosologico NULL, perche' significa che sono OSCURATI PUNTUALMENTE
		--
		RIGHT JOIN FiltroRicoveri AS TAB
			ON TAB.NumeroNosologico = R.NumeroNosologico
			 AND TAB.AziendaErogante = R.AziendaErogante

		--
		-- FACENDO UNA LEFT QUESTA EQUIVALE AD UN LOOK UP E SIAMO SICURI CHE VIENE ESEGUTA DOPO  LA PRIMA JOIN DI FILTRO
		--
		LEFT OUTER JOIN [sac].[Pazienti] AS P
						ON TAB.IdPAziente = P.Id

		LEFT OUTER JOIN dbo.PazientiAnteprima AS PA
			ON PA.IdPaziente = TAB.IdPaziente

		OUTER APPLY dbo.ParseAnteprimaReferti(PA.AnteprimaReferti) AS AR

	WHERE 
		(@ViewAll = 1) 
		OR 
		(
			([dbo].[CheckRicoveroOscuramenti](@IdRuolo, R.AziendaErogante, R.NumeroNosologico) = 1)
		)

	ORDER BY 
	--DEFAULT 
	CASE @Ordinamento WHEN '' THEN P.Cognome END DESC
	, CASE @Ordinamento WHEN '' THEN P.Nome END DESC

	--ASCENDENTE
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

	--DISCENDENTE
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