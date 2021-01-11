



CREATE PROCEDURE [dbo].[ConsensiWsByTesseraPaziente]
(
	@Identity varchar(64),
	@Tessera varchar(16)
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-14:
		Sostituito il nome della vista ConsensiOutputResult con ConsensiSpResult. 
		Inoltre la vista ConsensiSpResult restituisce i consensi del blocco di fusione già raggruppati per ootenere i consensi "più validi"

	MODIFICA ETTORE 2016-01-11: Getsione del nuovo campo XML Attributi
*/
	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggeConsensiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Identity, 0, 'ConsensiCercaByTesseraPaziente', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante ConsensiCercaByTesseraPaziente!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	DECLARE @IdPaziente uniqueidentifier
	SELECT TOP 1 @IdPaziente = Id FROM Pazienti WHERE Tessera = @Tessera ORDER BY LivelloAttendibilita DESC, DataModifica DESC
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
		PazienteTessera = @Tessera
	OR IdPaziente = @IdPaziente 

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsByTesseraPaziente] TO [DataAccessWs]
    AS [dbo];

