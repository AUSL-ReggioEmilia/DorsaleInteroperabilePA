
CREATE PROCEDURE [dbo].[UtentiUiInsert]
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
	-- Inserisce record
	---------------------------------------------------
	
	INSERT INTO dbo.Utenti
		( Utente
		, Descrizione
		, Dipartimentale
		, EmailResponsabile
		, Disattivato)
	VALUES
		( @Utente
		, @Descrizione
		, @Dipartimentale
		, @EmailResponsabile
		, @Disattivato)

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
    ON OBJECT::[dbo].[UtentiUiInsert] TO [DataAccessUi]
    AS [dbo];

