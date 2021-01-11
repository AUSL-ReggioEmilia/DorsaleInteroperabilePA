CREATE PROCEDURE [dbo].[BevsRefertiNoteRimuovi]
(
@IdRefertiNote uniqueidentifier
)
AS
SET NOCOUNT ON;
DELETE FROM RefertiNote
WHERE Id = @IdRefertiNote
SET NOCOUNT OFF;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiNoteRimuovi] TO [ExecuteFrontEnd]
    AS [dbo];

