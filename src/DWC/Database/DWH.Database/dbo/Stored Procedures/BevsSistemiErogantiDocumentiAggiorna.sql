CREATE PROCEDURE [dbo].[BevsSistemiErogantiDocumentiAggiorna]
(
@Id					uniqueidentifier,
@IdSistemaErogante	uniqueidentifier,
@Nome				varchar(256),
@Estensione			varchar(10),
@Dimensione			int,
@ContentType		varchar(256),
@Contenuto			image
)
AS
SET NOCOUNT ON;

UPDATE SistemiErogantiDocumenti 
	SET 
		IdSistemaErogante = @IdSistemaErogante,
		Nome = @Nome,
		Estensione = @Estensione,
		Dimensione = @Dimensione,
		ContentType = @ContentType,
		Contenuto = @Contenuto
WHERE SistemiErogantiDocumenti.ID = @Id

SET NOCOUNT OFF;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiDocumentiAggiorna] TO [ExecuteFrontEnd]
    AS [dbo];

