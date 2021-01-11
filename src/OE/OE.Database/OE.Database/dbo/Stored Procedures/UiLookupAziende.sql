

-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Lookup sulle azienda sanitaria 
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupAziende]

	@Codice varchar(16) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT Codice, Descrizione	
			FROM Aziende
			WHERE Codice = @Codice or @Codice is null
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END











GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupAziende] TO [DataAccessUi]
    AS [dbo];

