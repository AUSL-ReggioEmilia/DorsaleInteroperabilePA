
CREATE PROCEDURE [dbo].[IstatUiComboProvince]

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT	 
		Codice, 
		Nome
	FROM
		IstatProvince
	ORDER BY 
		Nome

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatUiComboProvince] TO [DataAccessUi]
    AS [dbo];

