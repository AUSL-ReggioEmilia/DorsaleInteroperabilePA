
CREATE PROCEDURE [dbo].[PazientiUiComboRegioni]

AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT Codice, Nome
	FROM IstatRegioni

	UNION

	SELECT 
		null as Codice
		, '- seleziona la regione -' as Nome

	ORDER BY Nome

END















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiComboRegioni] TO [DataAccessUi]
    AS [dbo];

