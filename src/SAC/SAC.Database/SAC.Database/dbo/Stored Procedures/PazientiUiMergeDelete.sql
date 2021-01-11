

-- =============================================
-- Author:		
-- Create date: 
-- Modify date: 2017-09-07 ETTORE: utilizzo della SP di core PazientiBaseDemerge
-- Description:	Esegue il demerge di un fuso
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiMergeDelete]
(
	  @IdPaziente uniqueidentifier		--La ROOT della catena di fusione
	, @IdPazienteFuso uniqueidentifier	--L'anagrafica da staccare dalla catena di fusione
	, @Utente AS varchar(64)
)
AS
BEGIN
/*
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
*/

DECLARE @Provenienza varchar(16)
DECLARE @IdProvenienza varchar(64)


	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	--  Esegue la cancellazione delle fusioni
	---------------------------------------------------

	DELETE FROM PazientiFusioni
		WHERE 
			    IdPaziente = @IdPaziente
			AND IdPazienteFuso = @IdPazienteFuso

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--  Esegue la cancellazione dei sinonimi
	---------------------------------------------------
	SELECT @Provenienza = Provenienza, @IdProvenienza = IdProvenienza FROM Pazienti WHERE Id = @IdPazienteFuso

	DELETE FROM PazientiSinonimi
		WHERE 
			    IdPaziente = @IdPaziente
			AND Provenienza = @Provenienza
			AND IdProvenienza = @IdProvenienza

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @IdPaziente, '1', @Utente
	exec PazientiNotificheAdd @IdPazienteFuso, '1', @Utente

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	COMMIT	
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	RETURN 1

END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiMergeDelete] TO [DataAccessUi]
    AS [dbo];

