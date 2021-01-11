

CREATE VIEW [dbo].[DizionarioMediciDiBaseOutput]
AS

	SELECT 
		Codice, CodiceFiscale, CognomeNome, Distretto

	FROM 
		DizionarioMediciDiBase



GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciDiBaseOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciDiBaseOutput] TO [DataAccessDizionari]
    AS [dbo];

