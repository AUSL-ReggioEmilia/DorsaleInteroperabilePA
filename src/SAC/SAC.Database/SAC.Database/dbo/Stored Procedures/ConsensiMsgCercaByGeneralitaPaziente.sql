
CREATE PROCEDURE [dbo].[ConsensiMsgCercaByGeneralitaPaziente]
	  @PazienteCognome varchar(64)
	, @PazienteNome varchar(64)
	, @PazienteDataNascita datetime
	, @Utente AS varchar(64)

AS
BEGIN

DECLARE @PazienteId AS uniqueidentifier
DECLARE @Msg AS varchar(255)

	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	
	IF dbo.LeggeConsensiPermessiLettura(@Utente) = 0
		BEGIN
			EXEC PazientiEventiAccessoNegato @Utente, 0, 'ConsensiMsgCercaPazienteByIdProvenienza', 'Utente non ha i permessi di lettura!'

			RAISERROR('Errore di controllo accessi!', 16, 1)
			RETURN 1002
		END

	---------------------------------------------------
	--  Cerco il paziente
	---------------------------------------------------

	SELECT TOP 1 @PazienteId = Id FROM Pazienti 
		WHERE Disattivato = 0 AND Cognome = @PazienteCognome AND Nome = @PazienteNome AND DataNascita = @PazienteDataNascita
		ORDER BY LivelloAttendibilita DESC, DataModifica DESC

	---------------------------------------------------
	--  Paziente non trovato
	---------------------------------------------------
--	IF @PazienteId IS NULL
--		BEGIN
--			SET @Msg = 'Paziente non trovato! Valore ricerca: PazienteCognome = ' 
--					+ ISNULL(@PazienteCognome, '') + ', PazienteNome = ' 
--					+ ISNULL(@PazienteNome, '') + ', PazienteDataNascita = ' 
--					+ ISNULL(CAST(@PazienteDataNascita AS VARCHAR(29)), '')
--			RAISERROR(@Msg, 16, 1)
--			RETURN 1003
--		END



	SELECT @PazienteId AS PazienteId

END



















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiMsgCercaByGeneralitaPaziente] TO [DataAccessDll]
    AS [dbo];

