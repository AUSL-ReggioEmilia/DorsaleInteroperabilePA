

CREATE VIEW [dbo].[DizionarioIstatRegioniOutput]
AS

	SELECT 
		Codice, Nome

	FROM 
		IstatRegioni



GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatRegioniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatRegioniOutput] TO [DataAccessDizionari]
    AS [dbo];

