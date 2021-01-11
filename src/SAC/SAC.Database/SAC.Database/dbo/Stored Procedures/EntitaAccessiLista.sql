

CREATE PROCEDURE [dbo].[EntitaAccessiLista]
AS
BEGIN
	SET NOCOUNT ON;
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT     
		Id
	  , Nome
	  , Descrizione1
	  , Descrizione2
	  , Descrizione3
	  , Dominio
	  , Tipo
	  , Amministratore

	FROM         
		EntitaAccessi
	ORDER BY Dominio, Nome

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[EntitaAccessiLista] TO [DataAccessUi]
    AS [dbo];

