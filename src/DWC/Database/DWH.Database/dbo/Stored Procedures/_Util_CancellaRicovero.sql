
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[_Util_CancellaRicovero]
(
	@AziendaErogante VARCHAR(16)
	, @NumeroNosologico VARCHAR(64)
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
		DELETE FROM store.EventiAttributi WHERE IdEventiBase IN (
			SELECT id FROM store.EventiBase 
			WHERE AziendaErogante = @AziendaErogante
					AND NumeroNosologico = @NumeroNosologico
					)
		--
		-- Cancello EventiBase
		--
		DELETE FROM store.EventiBase 
		WHERE AziendaErogante = @AziendaErogante
				AND NumeroNosologico = @NumeroNosologico
		--
		-- Cancello RicoveriAttributi
		--
		DELETE FROM store.RicoveriAttributi WHERE IdRicoveriBase IN (
			SELECT id FROM store.RicoveriBase 
			WHERE AziendaErogante = @AziendaErogante
					AND NumeroNosologico = @NumeroNosologico
			)
		--
		-- Cancello Ricovero
		--
		DELETE FROM store.RicoveriBase
			WHERE AziendaErogante = @AziendaErogante
					AND NumeroNosologico = @NumeroNosologico
	
		COMMIT 
		
		PRINT '_Util_CancellaRicovero: cancellato il ricovero: ' + @AziendaErogante + '-' + @NumeroNosologico
		
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
		SELECT @report = N'_Util_CancellaRicovero. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
	
	END CATCH
	


END
