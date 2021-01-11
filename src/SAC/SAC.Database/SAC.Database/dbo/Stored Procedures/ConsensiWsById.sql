

CREATE PROCEDURE [dbo].[ConsensiWsById]
(
	@Identity varchar(64),
	@Id uniqueidentifier
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-11: Getsione del nuovo campo XML Attributi
*/
	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggeConsensiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Identity, 0, 'ConsensiWsById', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante ConsensiWsById!', 16, 1)
		RETURN
	END
	--
	-- Cerco l'IdPaziente a cui il consesno è associato e lo traslo nell'attivo
	--
	DECLARE @IdPazientePadre UNIQUEIDENTIFIER
	SELECT @IdPazientePadre = IdPaziente FROM Consensi WHERE Id = @Id
	SET @IdPazientePadre = dbo.GetPazienteRootByPazienteId(@IdPazientePadre)
	--
	-- Restituzione dei dati
	--
	SELECT
		  C.Id
		, C.Provenienza
		, C.IdProvenienza
		, @IdPazientePadre AS IdPaziente
		, CT.Nome AS Tipo
		, C.DataStato
		, C.Stato
		, C.OperatoreId
		, C.OperatoreCognome
		, C.OperatoreNome
		, C.OperatoreComputer
		--I dati del paziente li leggo dall'anagrafica attiva associata a Consensi.IdPaziente 
		, P.Cognome AS PazienteCognome
		, P.Nome AS PazienteNome
		, P.Tessera AS PazienteTessera
		, P.CodiceFiscale PazienteCodiceFiscale
		, P.DataNascita AS PazienteDataNascita
		, P.ComuneNascitaCodice AS PazienteComuneNascitaCodice
		, dbo.LookupIstatComuni(P.ComuneNascitaCodice) AS PazienteComuneNascitaNome
		, P.NazionalitaCodice AS PazienteNazionalitaCodice
		, dbo.LookupIstatNazioni(P.NazionalitaCodice) AS PazienteNazionalitaNome
		--Converto l'xml degli attributi come se lo aspettano i WS
		, dbo.WsGetAttributi(C.Attributi) AS Attributi
	FROM 
		Consensi AS C
		INNER JOIN dbo.ConsensiTipo AS CT
			ON C.IdTipo = CT.Id		
		INNER JOIN Pazienti AS P
			ON @IdPazientePadre = P.Id 
	WHERE
		C.Id = @Id
		AND C.Disattivato = 0
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsById] TO [DataAccessWs]
    AS [dbo];

