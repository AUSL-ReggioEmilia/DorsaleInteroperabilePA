

CREATE PROCEDURE [dbo].[PazientiUiEsenzioniSelect]
	@Id AS uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT *
	FROM PazientiUiEsenzioniResult
	WHERE Id = @Id
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiEsenzioniSelect] TO [DataAccessUi]
    AS [dbo];

