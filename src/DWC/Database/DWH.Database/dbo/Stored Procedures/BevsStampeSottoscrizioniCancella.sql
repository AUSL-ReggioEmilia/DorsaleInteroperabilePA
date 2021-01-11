-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Cancellazione di una sottoscrizione
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniCancella]
(
	@Id UNIQUEIDENTIFIER
	, @Ts AS TIMESTAMP
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY

		DELETE SS_DC 
		FROM StampeSottoscrizioniDocumentiCoda AS SS_DC 
			INNER JOIN StampeSottoscrizioniCoda AS SS_C
				ON SS_DC.IdStampeSottoscrizioniCoda = SS_C.Id
		WHERE SS_C.IdStampeSottoscrizioni = @Id
	
		DELETE FROM StampeSottoscrizioniCoda
		WHERE IdStampeSottoscrizioni = @Id
		
		DELETE FROM StampeSottoscrizioniRepartiRichiedenti
		WHERE IdStampeSottoscrizioni = @Id

		DELETE FROM StampeSottoscrizioni
		WHERE Id = @Id AND Ts = @Ts 
		--
		-- COMMIT
		--	
		COMMIT
		
	END TRY
	BEGIN CATCH
		--
		-- Rollback delle modifiche
		--
		IF @@TRANCOUNT > 0
			ROLLBACK
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsStampeSottoscrizioniCancella. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	
	END CATCH
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniCancella] TO [ExecuteFrontEnd]
    AS [dbo];

