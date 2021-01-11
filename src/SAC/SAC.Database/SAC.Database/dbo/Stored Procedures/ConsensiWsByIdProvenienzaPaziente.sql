



CREATE PROCEDURE [dbo].[ConsensiWsByIdProvenienzaPaziente]
(
	@Identity varchar(64),
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)
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
		EXEC ConsensiEventiAccessoNegato @Identity, 0, 'ConsensiCercaByIdProvenienzaPaziente', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante ConsensiCercaByIdProvenienzaPaziente!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	
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
			(PazienteProvenienza = @Provenienza
		AND PazienteIdProvenienza = @IdProvenienza)
	OR
		( ConsensiSpResult.IdPaziente IN (
							SELECT PazientiSinonimi.IdPaziente
							FROM         
								PazientiSinonimi
							WHERE
									PazientiSinonimi.Provenienza = @Provenienza
								AND PazientiSinonimi.IdProvenienza = @IdProvenienza
										)

		)

	
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsByIdProvenienzaPaziente] TO [DataAccessWs]
    AS [dbo];

