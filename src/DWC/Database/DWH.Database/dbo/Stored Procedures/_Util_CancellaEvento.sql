
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Util_CancellaEvento]
(
	@IdEvento UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-12-12: usato le viste store invece delle tabelle
*/
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION 
	BEGIN TRY
		--
		-- Cancello Attributi degli eventi
		--
		DELETE FROM store.EventiAttributi WHERE IdEventiBase = @IdEvento
		--
		-- Cancello EventiBase
		--
		DELETE FROM store.EventiBase 
		WHERE Id = @IdEvento
	
		COMMIT 
		
		PRINT '_Util_CancellaEvento: cancellato l''evento: ' + CAST(@IdEvento AS VARCHAR(40))
		
	END TRY		
	BEGIN CATCH
		--
		-- Raise dell'errore + ROLLBACK
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		IF @@TRANCOUNT > 0 ROLLBACK
		
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'_Util_CancellaEvento. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
	
	END CATCH
	


END