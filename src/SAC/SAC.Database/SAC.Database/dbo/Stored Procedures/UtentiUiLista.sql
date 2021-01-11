


CREATE PROCEDURE [dbo].[UtentiUiLista]
	@Utente VARCHAR(64) = NULL
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
		@Utente IS NULL OR Utente LIKE '%'+ @Utente +'%'
END
















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiUiLista] TO [DataAccessUi]
    AS [dbo];

