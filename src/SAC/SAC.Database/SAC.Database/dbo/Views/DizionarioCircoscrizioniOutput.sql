






CREATE VIEW [dbo].[DizionarioCircoscrizioniOutput]
AS

	SELECT 
		SubComuneDom, SubComuneRes

	FROM 
		DizionarioCircoscrizioni







GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioCircoscrizioniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioCircoscrizioniOutput] TO [DataAccessDizionari]
    AS [dbo];

