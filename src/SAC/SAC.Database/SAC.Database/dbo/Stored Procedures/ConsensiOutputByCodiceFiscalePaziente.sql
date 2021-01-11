CREATE PROCEDURE [dbo].[ConsensiOutputByCodiceFiscalePaziente]
(
	@CodiceFiscale varchar(16)
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-19: 
		La versione precedente richiamava la SP ConsensiWsByCodiceFiscalePaziente(). Ho duplicato il codice.
		Restituisco l'xml degli attributi cosi come salvato nel database
	MODIFICA ETTORE 2016-05-02: 		
		Ho tolto la restituzione dell'XML degli attributi del consenso
	MODIFICA SANDRO 2016-05-26: 		
		Rimosso controllo accesso di lettura
*/
	SET NOCOUNT ON;
	
	IF @CodiceFiscale IS NULL
	BEGIN
		RAISERROR('Il parametro CodiceFiscale non può essere NULL!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	DECLARE @IdPaziente uniqueidentifier
	SELECT TOP 1 @IdPaziente = Id FROM Pazienti WHERE CodiceFiscale = @CodiceFiscale ORDER BY LivelloAttendibilita DESC, DataModifica DESC
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
		PazienteCodiceFiscale = @CodiceFiscale
	OR IdPaziente = @IdPaziente	

END












GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiOutputByCodiceFiscalePaziente] TO [DataAccessSql]
    AS [dbo];

