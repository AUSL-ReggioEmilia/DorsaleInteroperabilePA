

-- =============================================
-- Author:      SimoneB
-- Create date: 2017-10-16
-- Description: Completa l'inserimento di un nuovo oscuramento puntale (cancellazione del precedente oscuramento + modifica dello stato)
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiCompleta]
(
 @IdOscuramento UNIQUEIDENTIFIER
)
AS
BEGIN
	BEGIN TRANSACTION
	 BEGIN TRY
		--CANCELLO L'OSCURAMENTO CHE HA COME IdCorrelazione L'ID PASSATO.
		DELETE FROM dbo.Oscuramenti WHERE IdCorrelazione = @IdOscuramento

		--SETTO LO STATO A Completato E RESETTO IdCorrelazione.
		UPDATE dbo.Oscuramenti
		SET Stato = 'Completato',
			IdCorrelazione = NULL		
		WHERE Id = @IdOscuramento

		COMMIT

	END TRY
	BEGIN CATCH
		--
		-- Rollback delle modifiche
		--
		IF @@TRANCOUNT > 0 ROLLBACK
						
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsOscuramentiCompleta. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiCompleta] TO [ExecuteFrontEnd]
    AS [dbo];

