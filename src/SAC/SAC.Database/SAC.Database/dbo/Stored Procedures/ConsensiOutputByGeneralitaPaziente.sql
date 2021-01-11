CREATE PROCEDURE [dbo].[ConsensiOutputByGeneralitaPaziente]
(
	@Cognome varchar(64),
	@Nome varchar(64),
	@DataNascita as datetime,
	@ComuneNascitaCodice varchar(6)
)	
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-19: 
		La versione precedente richiamava la SP ConsensiWsByGeneralitaPaziente(). Ho duplicato il codice.
		Restituisco l'xml degli attributi cosi come salvato nel database
	MODIFICA ETTORE 2016-05-02: 		
		Ho tolto la restituzione dell'XML degli attributi del consenso
	MODIFICA SANDRO 2016-05-26: 		
		Rimosso controllo accesso di lettura
*/
	SET NOCOUNT ON;

	IF @Cognome IS NULL
	BEGIN
		RAISERROR('Il parametro Cognome non può essere NULL!', 16, 1)
		RETURN
	END

	IF @Nome IS NULL
	BEGIN
		RAISERROR('Il parametro Nome non può essere NULL!', 16, 1)
		RETURN
	END

	IF @DataNascita IS NULL
	BEGIN	
		RAISERROR('Il parametro DataNascita non può essere NULL!', 16, 1)
		RETURN
	END

	IF @ComuneNascitaCodice IS NULL
	BEGIN	
		RAISERROR('Il parametro ComuneNascitaCodice (ISTAT) non può essere NULL!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	DECLARE @IdPaziente uniqueidentifier
	SELECT TOP 1 @IdPaziente = Id 
	FROM Pazienti 
	WHERE Cognome = @Cognome AND Nome = @Nome AND DataNascita = @DataNascita AND ComuneNascitaCodice = @ComuneNascitaCodice
	ORDER BY LivelloAttendibilita DESC, DataModifica DESC
	
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

	WHERE (PazienteCognome = @Cognome)
		AND (PazienteNome = @Nome)
		AND (PazienteDataNascita = @DataNascita)
		AND (PazienteComuneNascitaCodice = @ComuneNascitaCodice)
	OR IdPaziente = @IdPaziente 

END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiOutputByGeneralitaPaziente] TO [DataAccessSql]
    AS [dbo];

