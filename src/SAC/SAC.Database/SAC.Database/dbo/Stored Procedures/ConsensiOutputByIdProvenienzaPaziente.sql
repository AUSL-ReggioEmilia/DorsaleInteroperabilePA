CREATE PROCEDURE [dbo].[ConsensiOutputByIdProvenienzaPaziente]
(
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-19: 
		La versione precedente richiamava la SP ConsensiWsByIdProvenienzaPaziente(). Ho duplicato il codice.
		Restituisco l'xml degli attributi cosi come salvato nel database	
	MODIFICA ETTORE 2016-05-02: 		
		Ho tolto la restituzione dell'XML degli attributi del consenso
	MODIFICA SANDRO 2016-05-26: 		
		Rimosso controllo accesso di lettura
*/
	SET NOCOUNT ON;

	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Il parametro Provenienza non può essere NULL!', 16, 1)
		RETURN
	END

	IF @IdProvenienza IS NULL
	BEGIN
		RAISERROR('Il parametro IdProvenienza non può essere NULL!', 16, 1)
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
    ON OBJECT::[dbo].[ConsensiOutputByIdProvenienzaPaziente] TO [DataAccessSql]
    AS [dbo];

