



-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-10-19
-- Description:	Seleziona l'azienda sanitaria per codice
-- =============================================
CREATE PROCEDURE [dbo].[CoreAziendeSelectByCodice]
	@Codice varchar(16)
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT Codice, Descrizione	
			FROM Aziende
			WHERE Codice = @Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreAziendeSelectByCodice] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreAziendeSelectByCodice] TO [DataAccessWs]
    AS [dbo];

