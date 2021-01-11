-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-10-12
-- Description: Rinotifica la fusione del paziente
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiRinotificaFusione]
	  @IdPaziente AS UNIQUEIDENTIFIER
	, @IdPazienteFuso UNIQUEIDENTIFIER 
	, @Utente AS VARCHAR(64)
AS
BEGIN	
	SET NOCOUNT ON;

	BEGIN TRY
							
		BEGIN TRANSACTION
		EXEC [dbo].[PazientiNotificheAdd]
			  @IdPaziente 
			, 5 --5=UI-notifica merge
			, @Utente
			, @IdPazienteFuso
			    
		COMMIT TRANSACTION
		SELECT CAST(0 AS INT) AS ERROR_CODE
    
    END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
		  ROLLBACK TRANSACTION;
		END

		DECLARE @ErrorLogId INT
		EXECUTE LogError @ErrorLogId OUTPUT;
		EXECUTE RaiseErrorByIdLog @ErrorLogId 
		
		SELECT @ErrorLogId AS ERROR_CODE
		
	END CATCH	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiRinotificaFusione] TO [DataAccessUi]
    AS [dbo];

