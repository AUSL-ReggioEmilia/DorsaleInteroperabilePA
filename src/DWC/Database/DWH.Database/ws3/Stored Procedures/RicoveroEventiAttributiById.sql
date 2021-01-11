

CREATE PROCEDURE [ws3].[RicoveroEventiAttributiById]
(
	@IdRicovero UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-17: 
		Restituisce tutti gli attributi degli eventi associati al ricovero @IdRicovero
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del ricovero
		Il controllo di accesso deve essere fatto sul record di testata del ricovero per questo motivo non c'è il parametro @IdToken
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
		ws3.Ricoveri
	WHERE 
		Id = @IdRicovero
	--
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
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
		ws3.Eventi AS Eventi
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

END