

CREATE PROCEDURE [dbo].[PazientiUiComboProvince]
	@CodiceRegione as varchar(2) = null

AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT Codice, Nome
	FROM IstatProvince
	WHERE (CodiceRegione = @CodiceRegione) OR (ISNULL(@CodiceRegione, 0) = 0)
	ORDER BY Nome

END











GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiComboProvince] TO [DataAccessUi]
    AS [dbo];

