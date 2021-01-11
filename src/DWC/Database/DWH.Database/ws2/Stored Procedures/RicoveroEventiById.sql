
CREATE PROCEDURE [ws2].[RicoveroEventiById]
(
	@IdRicovero UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveroEventiById
		Restituito il campo XML Oscuramenti
		Utilizzato i campi Anteprima e SpecialitaErogante restituiti dalla vista
*/
	SET NOCOUNT ON
	DECLARE @IdPaziente as uniqueidentifier
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
		@IdPaziente = IdPaziente
		,@NumeroNosologico = NumeroNosologico
		,@AziendaErogante = AziendaErogante
		,@SistemaErogante = SistemaErogante
	FROM 
		ws2.Ricoveri
	WHERE 
		Id = @IdRicovero
	--
	-- MODIFICA ETTORE 2012-09-07: traslo l'idpaziente nell'id del paziente attivo
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)

	--
	-- Ora restituisco la lista degli eventi associati al ricovero
	--
	SELECT 
		Eventi.Id
		,IdEsterno
		--MODIFICA ETTORE 2012-09-07: Restituisco l'IdPaziente attivo
		,@IdPaziente AS IdPaziente
		,@IdRicovero AS IdRicovero
		,DataInserimento
		,DataModifica
		,AziendaErogante
		,SistemaErogante
		,ISNULL(RepartoErogante,'') AS RepartoErogante --gestione NULL 
		,DataEvento
		,TipoEventoCodice
		,TipoEventoDescr
		,NumeroNosologico
		,ISNULL(TipoEpisodio,'') AS TipoEpisodio --gestione dei null
		,TipoEpisodioDescr   --supporta il null
		,ISNULL(RepartoCodice,'') AS RepartoRicoveroCodice --gestione dei null
		,ISNULL(RepartoDescr,'') AS RepartoRicoveroDescr --gestione dei null
		,Diagnosi --supporta il null
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		,Oscuramenti
	FROM 
		ws2.Eventi AS Eventi
	WHERE 
		(NumeroNosologico = @NumeroNosologico)
		AND (AziendaErogante = @AziendaErogante)
		AND (SistemaErogante = @SistemaErogante)

	ORDER BY
		NumeroNosologico
		, DataEvento 

	RETURN @@ERROR
	
END
