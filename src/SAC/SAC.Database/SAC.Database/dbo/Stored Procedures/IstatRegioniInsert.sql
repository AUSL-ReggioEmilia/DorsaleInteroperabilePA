
CREATE PROCEDURE [dbo].[IstatRegioniInsert]
	  @Codice varchar(2)
	, @Nome varchar(64)
	, @RipartizioneGeografica varchar(64)
	
AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inserisco la regione se non esiste
	---------------------------------------------------

	IF NOT dbo.LookupIstatRegioni(@Codice) IS NULL
	BEGIN
		RETURN 1
	END

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	
	INSERT INTO IstatRegioni
		( Codice
		, Nome
		, RipartizioneGeografica)
	VALUES
		( @Codice
		, @Nome
		, @RipartizioneGeografica)

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
    ON OBJECT::[dbo].[IstatRegioniInsert] TO [DataAccessDll]
    AS [dbo];

