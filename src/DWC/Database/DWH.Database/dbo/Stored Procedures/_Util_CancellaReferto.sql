
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Util_CancellaReferto]
(
	@IdRefertibase UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-12-12: usato le viste store invece delle tabelle
*/
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION 
	
	BEGIN TRY
		--SELECT * FROM store.AllegatiAttributi (nolock) WHERE 
		DELETE FROM store.AllegatiAttributi where 
		IdAllegatiBase IN (
			SELECT Id FROM store.AllegatiBase (nolock) WHERE IdRefertiBase = @IdRefertibase
		)
		--SELECT * FROM store.AllegatiBase
		DELETE FROM store.AllegatiBase 
		WHERE IdRefertiBase = @IdRefertibase

		--SELECT * FROM store.PrestazioniAttributi (nolock) WHERE 
		DELETE FROM store.PrestazioniAttributi where 
		IdPrestazioniBase IN (
			SELECT Id FROM store.PrestazioniBase (nolock) WHERE IdRefertiBase = @IdRefertibase
		)

		--SELECT * FROM store.PrestazioniBase
		DELETE FROM store.PrestazioniBase 
		WHERE IdRefertiBase = @IdRefertibase

		--SELECT * FROM store.RefertiAttributi
		DELETE FROM  store.RefertiAttributi
		WHERE  IdRefertiBase=@IdRefertiBase

		DELETE FROM store.RefertiBaseRiferimenti
		WHERE IdRefertiBase=@IdRefertiBase
		
		--SELECT * FROM store.RefertiBase
		DELETE FROM store.RefertiBase
		WHERE Id=@IdRefertiBase
		
		COMMIT
		
		PRINT '_Util_CancellaReferto: cancellato il referto con Id: ' + CAST(@IdRefertiBase AS VARCHAR(40))
		
	END TRY		
	BEGIN CATCH
		--
		-- Raise dell'errore + ROLLBACK
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		ROLLBACK
		
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'_Util_CancellaReferto. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
		
	END CATCH
	
END
