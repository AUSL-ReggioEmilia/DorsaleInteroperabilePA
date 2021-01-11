
CREATE PROCEDURE [dbo].[PazientiUiEsenzioniDeleteAll]
	  @IdPaziente AS uniqueidentifier
	, @Utente AS varchar(64)
AS
BEGIN

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	--  Esegue la cancellazione
	---------------------------------------------------

	DELETE FROM PazientiUiEsenzioniResult
	WHERE IdPaziente = @IdPaziente

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @IdPaziente, '1', @Utente

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati inseriti
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
    ON OBJECT::[dbo].[PazientiUiEsenzioniDeleteAll] TO [DataAccessUi]
    AS [dbo];

