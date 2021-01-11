CREATE PROCEDURE [dbo].[BevsSistemiErogantiDocumentiRimuovi]
(
@Id uniqueidentifier
)
AS

SET NOCOUNT ON;
DELETE FROM SistemiErogantiDocumenti
WHERE SistemiErogantiDocumenti.Id = @Id
SET NOCOUNT OFF;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiDocumentiRimuovi] TO [ExecuteFrontEnd]
    AS [dbo];

