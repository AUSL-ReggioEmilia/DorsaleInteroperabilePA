CREATE PROCEDURE [dbo].[ConsensiOutputCompleta]
(
	@DaData datetime,
	@AData datetime,
	@Tipo varchar(16)
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-01-19: Tolto * dalla select ed esplicitato i campi.
		Utilizzo la nuova vista ConsensiOutput2
		Aggiunto il campo Attributi
	MODIFICA ETTORE 2016-05-02: 		
		Ho tolto la restituzione dell'XML degli attributi del consenso
	MODIFICA SANDRO 2016-05-26: 		
		Rimosso controllo accesso di lettura
*/

	SET NOCOUNT ON;
	
	IF @DaData IS NULL
	BEGIN
		RAISERROR('Il parametro DaData non può essere NULL!', 16, 1)
		RETURN
	END

	IF @AData IS NULL
	BEGIN
		RAISERROR('Il parametro AData non può essere NULL!', 16, 1)
		RETURN
	END

	IF @Tipo IS NULL
	BEGIN
		RAISERROR('Il parametro Tipo non contiene un valore valido!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT 
		Id
		,Provenienza
		,IdProvenienza
		,IdPaziente
		,Tipo
		,DataStato
		,Stato
		,OperatoreId
		,OperatoreCognome
		,OperatoreNome
		,OperatoreComputer
		,PazienteProvenienza
		,PazienteIdProvenienza
		,PazienteCognome
		,PazienteNome
		,PazienteTessera
		,PazienteCodiceFiscale
		,PazienteDataNascita
		,PazienteComuneNascitaCodice
		,PazienteComuneNascitaNome
		,PazienteNazionalitaCodice
		,PazienteNazionalitaNome
	FROM
		ConsensiOutput2
	WHERE
			DataStato BETWEEN @DaData AND DATEADD(dd, 1, @AData)
		AND Tipo = @Tipo
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiOutputCompleta] TO [DataAccessSql]
    AS [dbo];

