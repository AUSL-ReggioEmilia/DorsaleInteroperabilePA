

-- =============================================
-- Author:      Ettore
-- Create date: 2017-03-23
-- Description: Rinotifica di un paziente
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiRinotificaPazienteAttivo]
	  @IdPaziente AS UNIQUEIDENTIFIER --IdPaziente ATTIVO
	, @Utente AS VARCHAR(64)
AS
BEGIN	
	SET NOCOUNT ON;
	BEGIN TRY
							
		BEGIN TRANSACTION
		EXEC [dbo].[PazientiNotificheAdd]
			  @IdPaziente 
			, 1 --1=UI-Modifica
			, @Utente
			, NULL

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
    ON OBJECT::[dbo].[PazientiUiRinotificaPazienteAttivo] TO [DataAccessUi]
    AS [dbo];

