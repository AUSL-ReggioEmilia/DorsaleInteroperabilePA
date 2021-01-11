
CREATE PROCEDURE [dbo].[UtentiUiUpdate]
	  @Utente AS varchar(64)
	, @Descrizione AS varchar(128)
	, @Dipartimentale AS varchar(128)
	, @EmailResponsabile AS varchar(128)
	, @Disattivato AS tinyint

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

	UPDATE dbo.Utenti
	SET Descrizione = @Descrizione
		, Dipartimentale = @Dipartimentale
		, EmailResponsabile = @EmailResponsabile
		, Disattivato = @Disattivato

	WHERE 
		Utente = @Utente

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati aggiornati
	---------------------------------------------------

	COMMIT
	
	SELECT *
	FROM dbo.Utenti
	WHERE Utente = @Utente
	
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
    ON OBJECT::[dbo].[UtentiUiUpdate] TO [DataAccessUi]
    AS [dbo];

