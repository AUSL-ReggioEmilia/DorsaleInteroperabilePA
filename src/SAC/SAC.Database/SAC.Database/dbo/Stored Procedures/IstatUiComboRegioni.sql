
CREATE PROCEDURE [dbo].[IstatUiComboRegioni]

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT	 
		Codice, 
		Nome
	FROM
		IstatRegioni
	WHERE
		Codice NOT IN ('-1','00')
	ORDER BY 
		Nome

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatUiComboRegioni] TO [DataAccessUi]
    AS [dbo];

