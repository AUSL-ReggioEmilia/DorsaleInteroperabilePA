
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-09-23
-- Description:	Seleziona una lista di DatiAccessoriDefault
-- =============================================
CREATE PROCEDURE [dbo].[CoreDatiAccessoriDefaultList]

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT Codice, Descrizione
		FROM DatiAccessoriDefault
		WHERE Attivo = 1
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriDefaultList] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreDatiAccessoriDefaultList] TO [DataAccessWs]
    AS [dbo];

