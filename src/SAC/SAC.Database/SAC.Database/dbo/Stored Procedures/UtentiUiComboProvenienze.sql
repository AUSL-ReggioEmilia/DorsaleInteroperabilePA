
CREATE PROCEDURE [dbo].[UtentiUiComboProvenienze]

AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT Provenienza, ISNULL(Provenienza + ' [' + Descrizione + ']', Provenienza) AS Descrizione
	FROM dbo.Provenienze

	UNION

	SELECT 
		null as Provenienza
		, '- seleziona provenienza -' as Descrizione

	ORDER BY Descrizione

END


















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiUiComboProvenienze] TO [DataAccessUi]
    AS [dbo];

