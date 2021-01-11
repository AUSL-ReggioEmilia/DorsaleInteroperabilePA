


CREATE PROCEDURE [dbo].[UtentiUiSelect]
   @Utente AS varchar(64)
	
AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT     
		Utente
	  , Descrizione
	  , Dipartimentale
	  , EmailResponsabile
	  , Disattivato

	FROM         
		dbo.Utenti

	WHERE
		Utente = @Utente

END











GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiUiSelect] TO [DataAccessUi]
    AS [dbo];

