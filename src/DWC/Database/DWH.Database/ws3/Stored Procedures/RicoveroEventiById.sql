



CREATE PROCEDURE [ws3].[RicoveroEventiById]
(
	@IdRicovero UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-16: Restituisce tutti gli eventi associati al ricovero @IdRicovero
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del ricovero
		Il controllo di accesso deve essere fatto sul record di testata del ricovero per questo motivo non c'è il parametro @IdToken		
		
		Questa SP viene utilizzata nella costruzione del dettaglio di un ricovero, quindi non è necessario restituire i seguenti campi:
			IdPaziente 
			IdRicovero
			AziendaErogante
			SistemaErogante
			RepartoErogante
			TipoEpisodio -> TipoEpisodioCodice
			TipoEpisodioDescr
			Cognome
			Nome
			CodiceFiscale
			DataNascita
			--, Sesso  -- manca DA AGGIUNGERE ALLA NUOVA VISTA WS3.Eventi oppure alla store.eventi
			ComuneNascita
			CodiceSanitario
*/
	SET NOCOUNT ON
	DECLARE @NumeroNosologico as varchar(64)
	DECLARE @AziendaErogante as varchar(16)
	DECLARE @SistemaErogante AS VARCHAR(16)
	--
	-- Uso la tabella Ricoveri
	--
	-- Da @IdRicovero = ID della tabella Ricoveri
	-- 1) il paziente associato al ricovero
	-- 2) il nosologico associato al ricovero
	-- 3) l'azienda erogante
	--
	SELECT 
		@NumeroNosologico = NumeroNosologico
		,@AziendaErogante = AziendaErogante
		,@SistemaErogante = SistemaErogante
	FROM 
		ws3.Ricoveri
	WHERE 
		Id = @IdRicovero
	--
	-- Ora restituisco la lista degli eventi associati al ricovero
	--
	SELECT 
		Eventi.Id
		, @IdRicovero AS IdRicovero 
		,IdEsterno
		,DataInserimento
		,DataModifica
		,DataEvento
		,TipoEventoCodice
		,TipoEventoDescr
		,NumeroNosologico
		,ISNULL(RepartoCodice,'') AS RepartoRicoveroCodice --gestione dei null
		,ISNULL(RepartoDescr,'') AS RepartoRicoveroDescr --gestione dei null
		---------------------------------
		-- NUOVI: 
		-- PER ORA LI HO AGGIUNTI ALLA VISTA WS3.Eventi (usando dbo.GetEventiAttributo(Id, <nomeattributo>) che non usa la data partizione!!!)
		-- SAREBBERO DA AGGIUNGERE ALLA VISTA store.eventi
		---------------------------------
		, SettoreCodice AS SettoreRicoveroCodice
		, SettoreDescr AS SettoreRicoveroDescr
		, LettoCodice AS LettoRicoveroCodice
		---------------------------------
		,Diagnosi 
	FROM 
		ws3.Eventi AS Eventi
	WHERE 
		(NumeroNosologico = @NumeroNosologico)
		AND (AziendaErogante = @AziendaErogante)
		AND (SistemaErogante = @SistemaErogante)

	ORDER BY
		NumeroNosologico
		, DataEvento 
	
END