


CREATE PROCEDURE [ws3].[RicoveriApertiEventiAttributiById]
(
	@IdRicoveri AS IdRicoveri READONLY
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-10-20: 
		Restituisce tutti gli attributi degli eventi associati ad un alista di ricoveri
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del ricovero
		Il controllo di accesso deve essere fatto sul record di testata del ricovero per questo motivo non c'è il parametro @IdToken
*/
	SET NOCOUNT ON

	DECLARE @IdPazienteAttivo as uniqueidentifier
	DECLARE @TAB_InfoRicoveri TABLE(IdRicovero UNIQUEIDENTIFIER, IdPaziente UNIQUEIDENTIFIER, NumeroNosologico VARCHAR(64), AziendaErogante VARCHAR(16), SistemaErogante VARCHAR(16))
	--
	-- Ricavo IdRicovero, Azienda, Nosologico, Paziente dalla tabella dei Ricoveri
	--
	INSERT INTO @TAB_InfoRicoveri (IdRicovero, IdPaziente, NumeroNosologico, AziendaErogante, SistemaErogante)
	SELECT 
		R.Id AS IdRicovero
		, R.IdPaziente
		, R.NumeroNosologico
		, R.AziendaErogante
		, R.SistemaErogante
	FROM 
		ws3.Ricoveri AS R
	WHERE 
		EXISTS(SELECT * FROM @IdRicoveri AS TAB WHERE TAB.Id = R.Id)
	--
	-- Traslo l'idpaziente nell'idpaziente attivo: uso un record della tabella temporanea che memorizza le info ricoveri
	--
	SELECT TOP 1 @IdPazienteAttivo = dbo.GetPazienteAttivoByIdSac(IdPaziente) FROM @TAB_InfoRicoveri
	--
	-- Ora restituisco tutti gli attributi degli eventi associati ai ricoveri 
	-- 
	SELECT
		TAB.IdRicovero
		, EA.IdEventiBase
		, EA.Nome
		, EA.Valore
	FROM 
		ws3.Eventi AS E
		--Faccio la join perchè mi serve anche l'id del ricovero associato
		INNER JOIN @TAB_InfoRicoveri AS TAB
			ON 	TAB.NumeroNosologico = E.NumeroNosologico 
				AND TAB.AziendaErogante = E.AziendaErogante 
				AND TAB.SistemaErogante  = E.SistemaErogante 
		INNER JOIN 
			store.EventiAttributi AS EA ON E.Id = EA.IdEventiBase
	WHERE 
		EXISTS (SELECT * FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo) AS Pazienti WHERE Pazienti.Id = E.IdPaziente)
		AND 
		EXISTS ( SELECT 
					* 
				FROM @TAB_InfoRicoveri AS TAB 
				WHERE 
					TAB.NumeroNosologico = E.NumeroNosologico 
					AND TAB.AziendaErogante = E.AziendaErogante 
					AND TAB.SistemaErogante  = E.SistemaErogante 
				)


END