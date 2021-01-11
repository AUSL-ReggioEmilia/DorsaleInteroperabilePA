


CREATE PROCEDURE [ws2].[RefertiByNumeroPrenotazione]
(
	@NumeroPrenotazione as varchar(32),
	@IdRuolo UNIQUEIDENTIFIER = NULL
)
AS
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertiByNumeroPrenotazione
		Restituito il campo XML Oscuramenti
		Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista

	Restituisce la lista dei referti per NumeroPrenotazione
	Limitazione record restituiti 
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto

	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
								Aggiunto controllo su numero prenotazione - viene comunque controllato nel WS
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @IdPaziente uniqueidentifier
	DECLARE @DallaData DATETIME

	IF ISNULL(@NumeroPrenotazione, '') = ''
	BEGIN
		RAISERROR('Il @NumeroPrenotazione deve essere valorizzato!', 16, 1)
		RETURN
	END
	--
	-- Limitazione record restituiti
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)	
	--
	-- Ricavo la data minima dalle configurazioni
	--
	IF @DallaData IS NULL
	BEGIN 
		SET @DallaData = DATEADD(day, - ISNULL([dbo].[GetConfigurazioneInt] ('Ws2','RefertiDaGiorni') , 3650), GETDATE())
	END 
	--
	-- Cerco nella ws2.Referti il/i pazienti associati al NumeroPrenotazione
	--
	SELECT TOP 1 @IdPaziente = IdPaziente
	FROM ws2.Referti
	WHERE NumeroPrenotazione = @NumeroPrenotazione
		And ISNULL(NumeroNosologico,'') = '' --questa comporta che vengono restituiti solo prenotazioni esterne cioè CUP, il NumeroPrenotazione dovrebbe essere univoco
		AND IdPaziente <> '00000000-0000-0000-0000-000000000000'	
		
	--MODIFICA ETTORE 2012-09-11: traslo l'idpaziente nell'idpaziente attivo		
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--PRINT '@IdPaziente (ATTIVO)= ' + CAST(@IdPaziente AS VARCHAR(40))

	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DallaDataPartizione DATETIME
	SELECT @DallaDataPartizione = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaData)
	--PRINT '@DallaDataPartizione = ' + ISNULL(CONVERT(VARCHAR(40), @DallaDataPartizione , 120), 'NULL')

	----------------------------------------------------------------------------------------------
	-- MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
	----------------------------------------------------------------------------------------------
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
			@Dalladata = [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, ConsensoAziendaleCodice, ConsensoAziendaleData)		
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
	-- Estrazione di tutti i referti legati al paziente
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
		ws2.Referti as R
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON R.IdPaziente = Pazienti.Id		
	WHERE 
		R.NumeroPrenotazione = @NumeroPrenotazione 
		--
		-- Con NumeroNosologico NON VALORIZZATO: cerco solo referti associati 
		-- a richieste esterne all'Ospedale cioè richieste fatte dal CUP
		--
		AND ISNULL(R.NumeroNosologico,'') = ''
		--
		-- Filtro in base alla data e alla data di partizione
		--
		AND (R.DataReferto>= @DallaData OR @DallaData IS NULL) 
		AND (R.DataPartizione >= @DallaDataPartizione )

	ORDER BY R.DataReferto DESC

	RETURN @@ERROR

END

