-- =============================================
-- Author:		Ettore
-- Create date: 2014-03-28
-- Description:	Combo dei codici di terminazione 
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiComboTerminazioni]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		Codice
		, ISNULL(Descrizione, Codice) AS Descrizione
	FROM
		DizionarioTerminazioni
		
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiComboTerminazioni] TO [DataAccessUi]
    AS [dbo];

