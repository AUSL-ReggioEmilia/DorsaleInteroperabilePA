CREATE PROCEDURE [dbo].[BevsSistemiErogantiDocumentiDettaglio]
(
@Id uniqueidentifier
)
AS
SET NOCOUNT ON;
SELECT 
	--Non leggo il valore 
	--CONVERT(IMAGE, NULL) AS Contenuto
	SistemiErogantiDocumenti.Contenuto
	,SistemiErogantiDocumenti.Id
	,SistemiErogantiDocumenti.Nome
	,SistemiErogantiDocumenti.Estensione
	,SistemiErogantiDocumenti.Dimensione
	,SistemiErogantiDocumenti.ContentType
	,SistemiErogantiDocumenti.IdSistemaErogante
FROM
	dbo.SistemiErogantiDocumenti
WHERE
	SistemiErogantiDocumenti.Id = @Id
SET NOCOUNT OFF;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiDocumentiDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

