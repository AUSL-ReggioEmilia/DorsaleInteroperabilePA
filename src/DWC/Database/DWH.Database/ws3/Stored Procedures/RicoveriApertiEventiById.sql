

CREATE PROCEDURE [ws3].[RicoveriApertiEventiById]
(
	@IdRicoveri AS IdRicoveri READONLY
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-10-20: Restituisce tutti le testate degli eventi associati ad una lista di ricoveri
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del ricovero
		Il controllo di accesso deve essere fatto sul record di testata del ricovero per questo motivo non c'è il parametro @IdToken		
*/

	SET NOCOUNT ON
	DECLARE @TAB_InfoRicoveri AS TABLE(IdRicovero UNIQUEIDENTIFIER, NumeroNosologico varchar(64), AziendaErogante varchar(16), SistemaErogante VARCHAR(16))
	--
	-- Ricavo info sui ricoveri per matchare gli eventi
	--
	INSERT INTO @TAB_InfoRicoveri (IdRicovero, NumeroNosologico, AziendaErogante, SistemaErogante)
	SELECT 
		Id AS IdRicovero
		, NumeroNosologico
		, AziendaErogante
		, SistemaErogante
	FROM 
		ws3.Ricoveri AS R
	WHERE 
		EXISTS (SELECT * FROM @IdRicoveri AS TAB WHERE TAB.Id = R.Id)
	--
	-- Ora restituisco la lista degli eventi associati al ricovero
	--
	SELECT 
		E.Id
		, IR.IdRicovero AS IdRicovero 
		,E.IdEsterno
		,E.DataInserimento
		,E.DataModifica
		,E.DataEvento
		,E.TipoEventoCodice
		,E.TipoEventoDescr
		,E.NumeroNosologico
		,ISNULL(E.RepartoCodice,'') AS RepartoRicoveroCodice --gestione dei null
		,ISNULL(E.RepartoDescr,'') AS RepartoRicoveroDescr --gestione dei null
		---------------------------------
		-- NUOVI: 
		-- PER ORA LI HO AGGIUNTI ALLA VISTA WS3.Eventi (usando dbo.GetEventiAttributo(Id, <nomeattributo>) che non usa la data partizione!!!)
		-- SAREBBERO DA AGGIUNGERE ALLA VISTA store.eventi
		---------------------------------
		, E.SettoreCodice AS SettoreRicoveroCodice
		, E.SettoreDescr AS SettoreRicoveroDescr
		, E.LettoCodice AS LettoRicoveroCodice
		---------------------------------
		,E.Diagnosi 
	FROM 
		ws3.Eventi AS E
		INNER JOIN @TAB_InfoRicoveri AS IR
			ON IR.NumeroNosologico = E.NumeroNosologico
				AND IR.AziendaErogante = E.AziendaErogante
				AND IR.SistemaErogante = E.SistemaErogante
	WHERE 
		EXISTS (SELECT * FROM @IdRicoveri AS TAB WHERE TAB.Id = IR.IdRicovero)

	ORDER BY
		E.AziendaErogante
		, E.NumeroNosologico
		, E.DataEvento 
	
END