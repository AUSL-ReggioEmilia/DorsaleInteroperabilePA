

CREATE VIEW [dbo].[DizionarioTerminazioniOutput]
AS

	SELECT 
		Codice, Descrizione

	FROM 
		DizionarioTerminazioni



GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioTerminazioniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioTerminazioniOutput] TO [DataAccessDizionari]
    AS [dbo];

