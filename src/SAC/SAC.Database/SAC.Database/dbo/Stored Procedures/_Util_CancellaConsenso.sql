

CREATE PROCEDURE [dbo].[_Util_CancellaConsenso]
(
	@IdConsenso uniqueidentifier
)
AS
BEGIN
/*
	Cancellazione di un consenso
*/
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY	
		DELETE FROM ConsensiNotificheUtenti WHERE IdConsensiNotifica IN (
			SELECT Id FROM ConsensiNotifiche WHERE IdConsenso = @IdConsenso
		)
		PRINT 'ConsensiNotificheUtenti: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		
		DELETE FROM ConsensiNotifiche WHERE IdConsenso = @IdConsenso
		PRINT 'ConsensiNotifiche : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		
		DELETE FROM Consensi WHERE id = @IdConsenso 	
		PRINT 'Consensi : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'

		COMMIT
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg as VARCHAR(4000)
		SET @ErrorMsg = ERROR_MESSAGE()
		RAISERROR (@ErrorMsg , 16,1)

		IF @@TRANCOUNT > 0
		BEGIN
		  ROLLBACK TRANSACTION;
		END
		
	END CATCH

END

