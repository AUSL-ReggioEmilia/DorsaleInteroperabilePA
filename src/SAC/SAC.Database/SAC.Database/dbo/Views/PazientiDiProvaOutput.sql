
CREATE VIEW [dbo].[PazientiDiProvaOutput]
AS


SELECT 
	Id
FROM
	dbo.PazientiDiProva WITH(NOLOCK)
GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiDiProvaOutput] TO [DataAccessSql]
    AS [dbo];

