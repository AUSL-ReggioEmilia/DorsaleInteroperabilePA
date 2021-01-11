CREATE PROCEDURE [dbo].[BevsSistemiErogantiDocumentiAggiungi]
(
@IdSistemaErogante	uniqueidentifier,
@Nome				varchar(256),
@Estensione			varchar(10),
@Dimensione			int,
@ContentType		varchar(256),
@Contenuto			image
)
AS
SET NOCOUNT ON;

DECLARE @NewGuid uniqueidentifier
SET @NewGuid = NewId()

INSERT INTO SistemiErogantiDocumenti (Id,IdSistemaErogante,Nome,Estensione,Dimensione,ContentType,Contenuto)
VALUES(@NewGuid, @IdSistemaErogante,@Nome,@Estensione,@Dimensione,@ContentType,@Contenuto)
--
-- Rileggo per avere l'ID del record
--
SELECT 
	Id
FROM 
	SistemiErogantiDocumenti 
WHERE 
	Id = @NewGuid

SET NOCOUNT OFF;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiDocumentiAggiungi] TO [ExecuteFrontEnd]
    AS [dbo];

