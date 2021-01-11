

-- =============================================
-- Author: ETTORE
-- Create date: 2017-09-07 ETTORE: 
-- Description:	Esegue il demerge di un fuso. Utilizza la SP di core PazientiBaseDemerge
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiMergeDelete2]
(
	  @IdPaziente uniqueidentifier		--La ROOT della catena di fusione
	, @IdPazienteFuso uniqueidentifier	--L'anagrafica da staccare dalla catena di fusione
	, @Utente AS varchar(64)
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
		--
		-- Eseguo il demerge del paziente attualmente fuso
		--
		EXEC [PazientiBaseDeMerge] @IdPazienteFuso
		--
		-- Inserisce record di notifica sia del paziente ROOT che del paziente che è stato staccato dalla catena di fusione 
		--
		EXEC PazientiNotificheAdd @IdPaziente, '1', @Utente
		EXEC PazientiNotificheAdd @IdPazienteFuso, '1', @Utente

		--Commit della transazione
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
		DECLARE @ErrorLogId INT
		EXECUTE dbo.LogError @ErrorLogId OUTPUT;
		EXECUTE RaiseErrorByIdLog @ErrorLogId 		
		RETURN @ErrorLogId
	END CATCH

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiMergeDelete2] TO [DataAccessUi]
    AS [dbo];

