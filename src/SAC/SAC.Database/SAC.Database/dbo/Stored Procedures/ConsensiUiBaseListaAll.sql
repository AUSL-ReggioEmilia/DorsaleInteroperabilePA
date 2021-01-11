


CREATE PROCEDURE [dbo].[ConsensiUiBaseListaAll]
(
	@IdPaziente AS uniqueidentifier,
	@IdTipo AS tinyint
)	
AS
BEGIN
	/*
		Trovo tutti i consensi associati al paziente @IdPaziente passato come parametro (il che equivale a tutti 
		i suoi e quelli dei suoi figli) e li restituisco ordinati per DataStato DESC, DataInserimento DESC
		
		Modifica Ettore 2014-05-23: 
			Ho restituito come IdPaziente L'IdPaziente passato come parametro cioè L'IdPaziente PADRE corrente
			In questo modo l'interfaccia web USER/ADMIN compone correttamente l'URL verso il dettaglio consenso

		MODIFICA ETTORE 2016-01-15: Restituito il campo Attributi
	*/

	SET NOCOUNT ON;
	DECLARE @ConsensiPaziente TABLE (Id UNIQUEIDENTIFIER, IdPaziente UNIQUEIDENTIFIER, IdTipo TINYINT, DataStato DATETIME, DataInserimento DATETIME, Disattivato TINYINT, Ordine INT, Livello INT, Attributi XML)

	INSERT INTO @ConsensiPaziente(Id , IdPaziente , IdTipo , DataStato , DataInserimento , Disattivato , Ordine, Livello, Attributi)
	SELECT 
		Consensi.Id	
		, Consensi.IdPaziente --questo è @IdPaziente = IdPadre corrente passato come parametro
		, Consensi.IdTipo
		, Consensi.DataStato 
		, Consensi.DataInserimento	
		, Consensi.Disattivato
		, 0 AS Ordine
		, 0 AS Livello
		, Attributi
	FROM 
		Consensi 
	WHERE
		IdPaziente = @IdPaziente
		AND IdTipo = @IdTipo --Filtro anche per idTipo
	UNION ALL
	SELECT 
		Consensi.Id	
		--, Consensi.IdPaziente
		, @IdPaziente AS IdPaziente --restituisco sempre L'IdPadre corrente che è quello del parametro
		, Consensi.IdTipo
		, Consensi.DataStato 
		, Consensi.DataInserimento	
		, Consensi.Disattivato	
		, TAB.Id AS Ordine
		, TAB.Livello
		, Attributi
	FROM 
		[dbo].[GetTreeFusione](@IdPaziente) AS TAB
		inner join Consensi 
			ON Consensi.IdPaziente = TAB.IdFiglio
	WHERE IdTipo = @IdTipo 	--Filtro anche per idTipo
	
	--
	-- Restituisco
	--
	SELECT 
		C.Id
		, C.DataInserimento
		, C.Disattivato
		, C.Provenienza
		, C.IdProvenienza
		, P.Id AS IdPaziente
		, C.IdTipo
		, CT.Nome AS Tipo
		, C.DataStato
		, C.Stato
		, C.OperatoreId
		, C.OperatoreCognome
		, C.OperatoreNome
		, C.OperatoreComputer
		, P.Provenienza AS PazienteProvenienza
		, P.IdProvenienza AS PazienteIdProvenienza
		, P.Cognome AS PazienteCognome
		, P.Nome AS PazienteNome
		, P.Tessera AS PazienteTessera
		, P.CodiceFiscale AS PazienteCodiceFiscale
		, P.DataNascita AS PazienteDataNascita
		, P.ComuneNascitaCodice AS PazienteComuneNascitaCodice
		, dbo.LookupIstatComuni(P.ComuneNascitaCodice) AS PazienteComuneNascitaNome
		, P.NazionalitaCodice AS PazienteNazionalitaCodice
		, dbo.LookupIstatNazioni(P.NazionalitaCodice) AS PazienteNazionalitaNome
		, CP.Attributi AS Attributi
	FROM 
		@ConsensiPaziente AS CP 
		INNER JOIN Consensi AS C
			ON C.Id = CP.id
		INNER JOIN ConsensiTipo AS CT
			ON CT.Id = C.IdTipo
		INNER JOIN Pazienti AS P
			ON P.Id = CP.IdPaziente
	WHERE		
		C.Disattivato = 0
	ORDER BY 
		--ordino per questi campi tanto ho già filtrato per IdPaziente e IdTipo
		DataStato DESC, DataInserimento DESC
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiUiBaseListaAll] TO [DataAccessUi]
    AS [dbo];

