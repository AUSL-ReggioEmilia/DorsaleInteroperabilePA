


CREATE PROCEDURE [ws2].[RefertiModificatiBySistema]
(
	@AziendaErogante	VARCHAR(16)
	, @SistemaErogante	VARCHAR(16)
	, @RepartoErogante	VARCHAR(64)=NULL
	, @RepartoRichiedenteCodice VARCHAR(16)=NULL
	, @DataDal			DATETIME
	, @DataAl			DATETIME=NULL
	, @IdRuolo UNIQUEIDENTIFIER = NULL
)WITH RECOMPILE
AS
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertiModificatiBySistema
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Restituito il campo XML Oscuramenti
		Restituito anche AziendaErogante e SistemaErogante
		
		NON HO CAMBIATO IL CALCOLO DELLA DATA DI FILTRO PER LA DATA PARTIZIONE!!!

	Restituisce Id (guid), IdEsterno, DataModifica, IdOrderEntry, IdPaziente (guid SAC), StatoRichiestaCodice

	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
								Il parametro @DataDal è obbligatorio. Non leggo la data minima da configurazione.
*/
BEGIN
	SET NOCOUNT ON
	--
	-- Controllo dei dati di input
	--
	IF @DataDal IS NULL
	BEGIN
		RAISERROR('Il parametro @DataDal è obbligatorio', 16, 1)
		RETURN
	END 
	--
	-- Aggiusto i valori dei parametri passati
	--
	IF @AziendaErogante = '' SET @AziendaErogante = NULL
	IF @SistemaErogante = '' SET @SistemaErogante = NULL
	IF @RepartoErogante = '' SET @RepartoErogante = NULL
	IF @RepartoErogante = '' SET @RepartoErogante = NULL
	IF @RepartoRichiedenteCodice = '' SET @RepartoRichiedenteCodice = NULL
	--
	-- Costruisco un limite inferiore per la data di partizione 
	--	
	DECLARE @DataPartizioneDal AS SMALLDATETIME
	IF @DataDal > '1901-01-01'
		--ATTENZIONE: questa va in errore se la data è 1900-01-01. Il più piccolo SMALLDATETIME è 1900-01-01
		SET @DataPartizioneDal = DATEADD(year, -1, @DataDal) 
	ELSE
		SET @DataPartizioneDal = '1900-01-01'
	--
	-- Limitazione record restituiti 
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)	

	----------------------------------------------------------------------------------------------
	-- MODIFICA ETTORE 2017-10-09: MODIFICA ETTORE 2017-10-09: Gestione filtro basato sul consenso 
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
	-- Estrazione dei referti modificati
	--
	SELECT TOP (@Top)
		R.Id AS IdDwh
		, R.IdEsterno
		, R.DataModifica
		, R.AziendaErogante
		, R.SistemaErogante
		, R.IdOrderEntry
		--Traslo l'idpaziente nell'idpaziente attivo		
		, dbo.GetPazienteAttivoByIdSac(R.IdPaziente) AS IdSac
		, R.StatoRichiestaCodice
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		, R.Oscuramenti
	FROM	
		ws2.Referti AS R
		CROSS APPLY sac.OttienePazientePerIdSac(R.IdPaziente) AS P
	WHERE 
		(R.AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		AND (R.SistemaErogante = @SistemaErogante OR @SistemaErogante IS NULL)
		AND (R.RepartoErogante = @RepartoErogante OR @RepartoErogante IS NULL)
		AND (R.RepartoRichiedenteCodice = @RepartoRichiedenteCodice OR @RepartoRichiedenteCodice IS NULL)
		--
		-- Filtro sulla data modifica passata come parametro
		--
		AND (@DataDal <= R.DataModifica AND (R.DataModifica <= @DataAl OR @DataAl IS NULL))
		--
		-- Filtro per DataReferto (DINAMICO SUL CONSENSO)
		--
		AND (
				(@ByPassaConsenso = 1) 
				OR
				(@ByPassaConsenso = 0 AND R.Datareferto >= [dbo].[GetDataMinimaByConsensoAziendale](@DataDal, P.ConsensoAziendaleCodice, P.ConsensoAziendaleData))
			)
		--
		-- Filtro per DataPartizione (STATICO)
		--
		AND R.Datapartizione >= @DataPartizioneDal
	
	ORDER BY R.DataModifica DESC

	RETURN @@ERROR

END


