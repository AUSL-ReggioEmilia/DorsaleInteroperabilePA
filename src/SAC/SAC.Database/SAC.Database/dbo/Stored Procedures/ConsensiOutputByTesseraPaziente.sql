CREATE PROCEDURE [dbo].[ConsensiOutputByTesseraPaziente]
(
	@Tessera varchar(16)
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-19: 
		La versione precedente richiamava la SP ConsensiWsByTesseraPaziente(). Ho duplicato il codice.
		Restituisco l'xml degli attributi cosi come salvato nel database
	MODIFICA ETTORE 2016-05-02: 		
		Ho tolto la restituzione dell'XML degli attributi del consenso
	MODIFICA SANDRO 2016-05-26: 		
		Rimosso controllo accesso di lettura
*/
	SET NOCOUNT ON;
	
	IF @Tessera IS NULL
	BEGIN
		RAISERROR('Il parametro TesseraSanitaria non può essere NULL!', 16, 1)
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
	FROM
		ConsensiSpResult
	WHERE
		PazienteTessera = @Tessera
	OR IdPaziente = @IdPaziente 	
END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiOutputByTesseraPaziente] TO [DataAccessSql]
    AS [dbo];

