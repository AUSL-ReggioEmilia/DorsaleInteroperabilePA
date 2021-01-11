





CREATE PROCEDURE [dbo].[ConsensiWsByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-14:
		Modificato il codice per usare la vista ConsensiSpResult che restituisce i consensi del blocco di fusione già raggruppati per ottenere i consensi "più validi"
		
	MODIFICA ETTORE 2016-01-11: Getsione del nuovo campo XML Attributi		
*/
	SET NOCOUNT ON;
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggeConsensiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Identity, 0, 'ConsensiWsByIdPaziente', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante ConsensiWsByIdPaziente!', 16, 1)
		RETURN
	END
	---------------------------------------------------
	--  Get del paziente padre
	---------------------------------------------------
	SET @IdPaziente = dbo.GetPazienteRootByPazienteId(@IdPaziente)

	SELECT
		  Id
		, Provenienza
		, IdProvenienza
		, IdPaziente
		, Tipo
		, DataStato
		, Stato
		, OperatoreId
		, OperatoreCognome
		, OperatoreNome
		, OperatoreComputer
		, PazienteCognome
		, PazienteNome
		, PazienteTessera
		, PazienteCodiceFiscale
		, PazienteDataNascita
		, PazienteComuneNascitaCodice
		, PazienteComuneNascitaNome
		, PazienteNazionalitaCodice
		, PazienteNazionalitaNome
		--Converto l'xml degli attributi come se lo aspettano i WS
		, dbo.WsGetAttributi(Attributi) AS Attributi
	FROM 
		ConsensiSpResult
	WHERE
		IdPaziente = @IdPaziente
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsByIdPaziente] TO [DataAccessWs]
    AS [dbo];

