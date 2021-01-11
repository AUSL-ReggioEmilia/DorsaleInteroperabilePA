
CREATE PROCEDURE [dbo].[ConsensiMsgUtentiAck]
	  @Utente AS varchar(64)
AS
BEGIN

	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT	  Utente
			, IngressoAck
			, IngressoAckUrl
			, NotificheAck
			, NotificheUrl
	FROM ConsensiUtenti
	WHERE Utente = @Utente
		OR NotificheAck = 1

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiMsgUtentiAck] TO [DataAccessDll]
    AS [dbo];

