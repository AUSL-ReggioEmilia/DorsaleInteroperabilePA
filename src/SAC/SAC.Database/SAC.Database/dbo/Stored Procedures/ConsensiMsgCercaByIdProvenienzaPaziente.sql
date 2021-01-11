
CREATE PROCEDURE [dbo].[ConsensiMsgCercaByIdProvenienzaPaziente]
	  @PazienteProvenienza varchar(16)
	, @PazienteIdProvenienza varchar(64)
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

	SELECT @PazienteId = Id FROM Pazienti 
		WHERE ((Provenienza = @PazienteProvenienza 
			AND IdProvenienza = @PazienteIdProvenienza)
			OR Id IN (
					SELECT IdPaziente FROM PazientiSinonimi
						WHERE Provenienza = @PazienteProvenienza
							AND IdProvenienza = @PazienteIdProvenienza
							AND Abilitato = 1
					)
			) AND Disattivato = 0
		ORDER BY Disattivato, LivelloAttendibilita, DataDisattivazione DESC

	---------------------------------------------------
	--  Paziente non trovato
	---------------------------------------------------
--	IF @PazienteId IS NULL
--		BEGIN
--			SET @Msg = 'Paziente non trovato! Valore ricerca: PazienteProvenienza = ' 
--					+ ISNULL(@PazienteProvenienza, '') + ', PazienteIdProvenienza = ' + ISNULL(@PazienteIdProvenienza, '') 
--			RAISERROR(@Msg, 16, 1)
--			RETURN 1003
--		END



	SELECT @PazienteId AS PazienteId

END



















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiMsgCercaByIdProvenienzaPaziente] TO [DataAccessDll]
    AS [dbo];

