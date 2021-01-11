
-- =============================================
-- Author:      Simone B.
-- Create date: 2017-11-09
-- Description: Inserisce i referti dentro CodaRefertiSole, CodaEventiSole e completa il salvataggio dell'oscuramento.
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiRinotificaSole]
(

	@IdOscuramento UNIQUEIDENTIFIER

)
AS
BEGIN
  SET NOCOUNT ON
	BEGIN TRANSACTION
	 BEGIN TRY
		
		--SALVO I REFERTI NELLA CODA DEI REFERTI DA RINOTIFICARE A SOLE.
		EXEC [dbo].[BevsOscuramentiCodaRefertiSoleInserisce] @IdOscuramento;

		--SALVO GLI EVENTI NELLA CODE DEGLI EVENTI DA RINOTIFICARE A SOLE.
		EXEC [dbo].[BevsOscuramentiCodaEventiSoleInserisce] @IdOscuramento

		--COMPLETO L'INSERIMENTO DELL'OSCURAMENTO: SETTO LO STATO A 'Completato' E RESETTO IdCorrelazione.
		EXEC [dbo].[BevsOscuramentiCompleta] @IdOscuramento

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
		SELECT @report = N'BevsOscuramentiRinotificaSole. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiRinotificaSole] TO [ExecuteFrontEnd]
    AS [dbo];

