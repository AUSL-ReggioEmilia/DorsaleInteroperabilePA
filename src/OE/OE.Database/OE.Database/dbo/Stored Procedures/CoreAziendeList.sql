



-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-10-20
-- Description:	Ritorna la lista delle aziende
-- =============================================
CREATE PROCEDURE [dbo].[CoreAziendeList]
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT Codice, Descrizione	FROM Aziende
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreAziendeList] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreAziendeList] TO [DataAccessWs]
    AS [dbo];

