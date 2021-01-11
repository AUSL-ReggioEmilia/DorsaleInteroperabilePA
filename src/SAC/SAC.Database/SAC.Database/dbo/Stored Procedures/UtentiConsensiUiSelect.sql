


CREATE PROCEDURE [dbo].[UtentiConsensiUiSelect]
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
		dbo.ConsensiUtenti

	WHERE
		Id = @Id

END












GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiConsensiUiSelect] TO [DataAccessUi]
    AS [dbo];

