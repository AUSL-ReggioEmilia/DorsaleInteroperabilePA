
-- =============================================
-- Author:	???
-- Create date: ???
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- =============================================
CREATE PROCEDURE [dbo].[BevsApreAllegatoContent] 
	@IdAllegato uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON

	SELECT    NomeFile, DataFile, MimeType, MimeData 
	FROM      store.Allegati
	WHERE     ID = @IdAllegato

	SET NOCOUNT OFF
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsApreAllegatoContent] TO [ExecuteFrontEnd]
    AS [dbo];

