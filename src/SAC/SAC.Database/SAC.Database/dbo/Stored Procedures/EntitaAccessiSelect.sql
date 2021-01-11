

CREATE PROCEDURE [dbo].[EntitaAccessiSelect]
(
	@Id AS UNIQUEIDENTIFIER = NULL
)
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
	  , CASE WHEN Tipo = 1 THEN 'Gruppo'
		ELSE 'Utente'
		END AS DescrizioneTipo
	  , Amministratore
	FROM         
		EntitaAccessi
	WHERE Id = @Id OR (@Id IS NULL)

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[EntitaAccessiSelect] TO [DataAccessUi]
    AS [dbo];

