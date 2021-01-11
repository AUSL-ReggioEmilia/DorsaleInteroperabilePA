
CREATE PROCEDURE [dbo].[PazientiUiMergeUpdate]
	  @IdPaziente AS uniqueidentifier
	, @Utente AS varchar(64)

AS
BEGIN

	SET NOCOUNT ON;	

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Aggiorna i dati senza controllo della concorrenza
	---------------------------------------------------

	UPDATE Pazienti
	SET   DataModifica = GetDate()
		--, DataSequenza = GetDate()
		, Disattivato = 0
		, DataDisattivazione = null
	
	WHERE Id = @IdPaziente

	IF @@ERROR <> 0 GOTO ERROR_EXIT


	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @IdPaziente, '1', @Utente
	

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
    ON OBJECT::[dbo].[PazientiUiMergeUpdate] TO [DataAccessUi]
    AS [dbo];

