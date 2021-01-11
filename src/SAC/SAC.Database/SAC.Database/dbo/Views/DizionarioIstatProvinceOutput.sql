

CREATE VIEW [dbo].[DizionarioIstatProvinceOutput]
AS

	SELECT 
		Codice, Nome, Sigla, CodiceRegione

	FROM 
		IstatProvince



GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatProvinceOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatProvinceOutput] TO [DataAccessDizionari]
    AS [dbo];

