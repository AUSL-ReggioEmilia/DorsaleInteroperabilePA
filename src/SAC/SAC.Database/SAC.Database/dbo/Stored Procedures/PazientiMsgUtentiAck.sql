
CREATE PROCEDURE [dbo].[PazientiMsgUtentiAck]
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
	FROM PazientiUtenti
	WHERE Utente = @Utente
		OR NotificheAck = 1

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgUtentiAck] TO [DataAccessDll]
    AS [dbo];

