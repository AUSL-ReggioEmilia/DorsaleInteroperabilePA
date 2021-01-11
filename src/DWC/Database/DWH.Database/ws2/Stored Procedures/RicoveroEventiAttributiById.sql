



CREATE PROCEDURE [ws2].[RicoveroEventiAttributiById]
(
	@IdRicovero UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveroEventiAttributiById
		Restituito il campo XML Oscuramenti
*/

	SET NOCOUNT ON

	DECLARE @IdPaziente as uniqueidentifier
	DECLARE @NumeroNosologico as varchar(64)
	DECLARE @AziendaErogante as varchar(16)
	DECLARE @SistemaErogante as varchar(16)
	--
	-- Ricavo Azienda, Nosologico, Paziente dalla tabella dei Ricoveri
	--
	--
	-- Da @IdRicovero (= ID del record della tabella dei ricoveri:  
	-- 1) il paziente associato al ricovero
	-- 2) il nosologico del ricovero
	-- 3) l'azienda erogante
	-- questi dati permettono di eseguire query su Eventi/EventiAttributi per 
	-- ottenere gli Attributi del Ricovero
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
		
	--MODIFICA ETTORE 2012-09-11: traslo l'idpaziente nell'idpaziente attivo			
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	
	--
	-- Ora restituisco tutti gli attributi degli eventi associati al ricovero
	--
	SELECT 
		EventiAttributi.IdEventiBase
		,EventiAttributi.Nome
		,EventiAttributi.Valore
	FROM 
		ws2.Eventi AS Eventi
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti AS Pazienti
			ON Eventi.IdPaziente = Pazienti.Id
		INNER JOIN 
			store.EventiAttributi ON Eventi.Id = EventiAttributi.IdEventiBase
	WHERE 
		(Eventi.NumeroNosologico = @NumeroNosologico)
		AND (Eventi.AziendaErogante = @AziendaErogante)
		AND (Eventi.SistemaErogante = @SistemaErogante)

	RETURN @@ERROR

END




