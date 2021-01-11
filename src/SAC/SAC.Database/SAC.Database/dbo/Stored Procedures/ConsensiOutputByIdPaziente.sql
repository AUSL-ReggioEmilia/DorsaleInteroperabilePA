CREATE PROCEDURE [dbo].[ConsensiOutputByIdPaziente]
(
	@IdPaziente uniqueidentifier
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-19: 
		La versione precedente richiamava la SP ConsensiWsByIdPaziente(). Ho duplicato il codice.
		Restituisco l'xml degli attributi cosi come salvato nel database
	MODIFICA ETTORE 2016-05-02: 		
		Ho tolto la restituzione dell'XML degli attributi del consenso
	MODIFICA SANDRO 2016-05-26: 		
		Rimosso controllo accesso di lettura
*/
	SET NOCOUNT ON;

	IF @IdPaziente IS NULL
	BEGIN
		RAISERROR('Il parametro IdPaziente non può essere NULL!', 16, 1)
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
	FROM 
		ConsensiSpResult
	WHERE
		IdPaziente = @IdPaziente	
END










GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiOutputByIdPaziente] TO [DataAccessSql]
    AS [dbo];

