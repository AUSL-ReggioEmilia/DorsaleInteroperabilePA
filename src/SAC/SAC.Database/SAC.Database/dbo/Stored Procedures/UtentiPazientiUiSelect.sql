


CREATE PROCEDURE [dbo].[UtentiPazientiUiSelect]
   @Id AS uniqueidentifier
	
AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT
		Id
	  , Utente
	  , Provenienza
	  , Lettura
	  , Scrittura
	  , Cancellazione
	  , LivelloAttendibilita
	  , IngressoAck
	  , IngressoAckUrl
	  , NotificheAck
	  , NotificheUrl
	  , Disattivato

	FROM         
		dbo.PazientiUtenti

	WHERE
		Id = @Id

END












GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiPazientiUiSelect] TO [DataAccessUi]
    AS [dbo];

