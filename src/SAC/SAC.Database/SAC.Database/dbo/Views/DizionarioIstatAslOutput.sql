

CREATE VIEW [dbo].[DizionarioIstatAslOutput]
AS

	SELECT 
		Codice, CodiceComune, Nome, CodiceAslRegione

	FROM 
		IstatAsl



GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatAslOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatAslOutput] TO [DataAccessDizionari]
    AS [dbo];

