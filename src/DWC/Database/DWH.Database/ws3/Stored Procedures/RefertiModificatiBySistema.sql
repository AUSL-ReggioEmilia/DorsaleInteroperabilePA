
CREATE PROCEDURE [ws3].[RefertiModificatiBySistema]
(
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER
	, @Ordinamento		VARCHAR(128)
	, @ByPassaConsenso	BIT
	, @AziendaErogante	VARCHAR(16)
	, @SistemaErogante	VARCHAR(16)
	, @RepartoErogante	VARCHAR(64)=NULL
	, @RepartoRichiedenteCodice VARCHAR(16)=NULL
	, @DallaData		DATETIME
	, @AllaData			DATETIME=NULL
)WITH RECOMPILE
AS
/*
	CREATA DA ETTORE 2016-03-15:
	Restituisce Id (guid), IdEsterno, DataModifica, IdOrderEntry, IdPaziente (guid SAC), StatoRichiestaCodice
	MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
*/
BEGIN
	SET NOCOUNT ON
	--
	-- Controllo dei dati di input
	--
	IF @DallaData IS NULL
	BEGIN
		RAISERROR('Il parametro @DallaData è obbligatorio', 16, 1)
		RETURN
	END 
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
	--
	-- MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
	--
	IF @ByPassaConsenso = 1
	BEGIN
		IF NOT EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) WHERE Accesso = 'ATTRIB@ACCES_NEC_CLIN')
		BEGIN
			DECLARE @Errore NVARCHAR(4000);
			SET @Errore= N'[SecurityError]Il ruolo corrente non ha il permesso di bypassare il consenso.' 
			RAISERROR(@Errore, 16, 1)
			RETURN
		END
	END
	--
	-- Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	--
	-- Aggiusto i valori dei parametri passati
	--
	IF @AziendaErogante = '' SET @AziendaErogante = NULL
	IF @SistemaErogante = '' SET @SistemaErogante = NULL
	IF @RepartoErogante = '' SET @RepartoErogante = NULL
	IF @RepartoErogante = '' SET @RepartoErogante = NULL
	IF @RepartoRichiedenteCodice = '' SET @RepartoRichiedenteCodice = NULL
	--
	-- Costruisco un limite inferiore per la data di partizione (INDIPENDENTE DAL CONSENSO)
	--	
	DECLARE @DataPartizioneDal AS SMALLDATETIME
	IF @DallaData > '1901-01-01'
		--ATTENZIONE: questa va in errore se la data è 1900-01-01. Il più piccolo SMALLDATETIME è 1900-01-01
		SET @DataPartizioneDal = DATEADD(year, -1, @DallaData) 
	ELSE
		SET @DataPartizioneDal = '1900-01-01'
	--
	-- Limitazione records restituiti da database
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Referti') , 2000)	
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top	
	--
	-- Estrazione dei referti modificati
	--
	SELECT TOP (@MaxNumRow)
		R.Id
		, R.IdEsterno
		, R.DataModifica
		, R.AziendaErogante
		, R.SistemaErogante
		, R.IdOrderEntry
		--Traslo l'idpaziente nell'idpaziente attivo		
		, dbo.GetPazienteAttivoByIdSac(R.IdPaziente) AS IdPaziente
		--, ISNULL(P.FusioneId, P.Id) AS IdSac
		, R.StatoRichiestaCodice
	FROM	
		ws3.Referti AS R
		CROSS APPLY sac.OttienePazientePerIdSac(R.IdPaziente) AS P
	WHERE 
		--
		-- Filtro per Sistema e Oscuramenti
		--
		(
			(@ViewAll = 1) 
			OR 
			(
				EXISTS( SELECT * FROM [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
						WHERE   R.SistemaErogante = SE.SistemaErogante AND  R.AziendaErogante = SE.AziendaErogante)
				AND 
				([dbo].[CheckRefertoOscuramenti] (@IdRuolo, R.Id, R.DataPartizione, R.AziendaErogante, R.SistemaErogante
												, R.StrutturaEroganteCodice, R.NumeroNosologico, R.RepartoRichiedenteCodice
												, R.RepartoErogante, R.Confidenziale ) = 1)
			)
		) 				
		AND (R.AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		AND (R.SistemaErogante = @SistemaErogante OR @SistemaErogante IS NULL)
		AND (R.RepartoErogante = @RepartoErogante OR @RepartoErogante IS NULL)
		AND (R.RepartoRichiedenteCodice = @RepartoRichiedenteCodice OR @RepartoRichiedenteCodice IS NULL)
		--
		-- Filtro sulla data modifica passata come parametro
		--
		AND (R.DataModifica >= @DallaData AND (R.DataModifica <= @AllaData OR @AllaData IS NULL))
		--
		-- Filtro per DataReferto (DINAMICO SUL CONSENSO)
		--
		AND (
				(@ByPassaConsenso = 1) 
				OR
				(@ByPassaConsenso = 0 AND R.Datareferto >= [dbo].[GetDataMinimaByConsensoAziendale](@Dalladata, P.ConsensoAziendaleCodice, P.ConsensoAziendaleData))
			)
		--
		-- Filtro per DataPartizione (STATICO)
		--
		AND (R.Datapartizione >= @DataPartizioneDal)
		
	ORDER BY 
	--Default
	CASE @Ordinamento  WHEN '' THEN R.DataModifica END DESC
	--Ascendente	
	, CASE @Ordinamento  WHEN 'Id@ASC' THEN R.Id END ASC
	, CASE @Ordinamento  WHEN 'IdEsterno@ASC' THEN R.IdEsterno END ASC
	, CASE @Ordinamento  WHEN 'DataModifica@ASC' THEN R.DataModifica END ASC
	, CASE @Ordinamento  WHEN 'AziendaErogante@ASC' THEN R.AziendaErogante END ASC
	, CASE @Ordinamento  WHEN 'SistemaErogante@ASC' THEN R.SistemaErogante END ASC
	, CASE @Ordinamento  WHEN 'IdOrderEntry@ASC' THEN R.IdOrderEntry END ASC 
	, CASE @Ordinamento  WHEN 'IdPaziente@ASC' THEN dbo.GetPazienteAttivoByIdSac(R.IdPaziente) END ASC
	, CASE @Ordinamento  WHEN 'StatoRichiestaCodice@ASC' THEN R.StatoRichiestaCodice END ASC
    --Discendente	
	, CASE @Ordinamento  WHEN 'Id@DESC' THEN R.Id END DESC
	, CASE @Ordinamento  WHEN 'IdEsterno@DESC' THEN R.IdEsterno END DESC
	, CASE @Ordinamento  WHEN 'DataModifica@DESC' THEN R.DataModifica END DESC
	, CASE @Ordinamento  WHEN 'AziendaErogante@DESC' THEN R.AziendaErogante END DESC
	, CASE @Ordinamento  WHEN 'SistemaErogante@DESC' THEN R.SistemaErogante END DESC
	, CASE @Ordinamento  WHEN 'IdOrderEntry@DESC' THEN R.IdOrderEntry END DESC 
	, CASE @Ordinamento  WHEN 'IdPaziente@DESC' THEN dbo.GetPazienteAttivoByIdSac(R.IdPaziente) END DESC
	, CASE @Ordinamento  WHEN 'StatoRichiestaCodice@DESC' THEN R.StatoRichiestaCodice END DESC

END