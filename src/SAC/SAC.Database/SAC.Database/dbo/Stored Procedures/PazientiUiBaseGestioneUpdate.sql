

CREATE PROCEDURE [dbo].[PazientiUiBaseGestioneUpdate]
	  @Id AS uniqueidentifier
	, @Disattivato tinyint
	, @DataDisattivazione datetime
	, @Occultato bit
	, @Utente AS varchar(64)

AS
BEGIN

	SET NOCOUNT ON
	
	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Aggiorna i dati
	---------------------------------------------------

	UPDATE Pazienti
	SET   DataModifica = GetDate()
		--, DataSequenza = GetDate()
		, Disattivato = @Disattivato
		, DataDisattivazione = @DataDisattivazione
		, Occultato = @Occultato
		
	WHERE Id = @Id

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @Id, '1', @Utente

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati aggiornati
	---------------------------------------------------

	COMMIT
	
	SELECT *
	FROM PazientiUiBaseGestioneResult
	WHERE Id = @Id
	
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
    ON OBJECT::[dbo].[PazientiUiBaseGestioneUpdate] TO [DataAccessUi]
    AS [dbo];

