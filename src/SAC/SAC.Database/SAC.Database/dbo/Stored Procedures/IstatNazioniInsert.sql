
CREATE PROCEDURE [dbo].[IstatNazioniInsert]
	  @Codice varchar(3)
	, @Nome varchar(64)

AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inserisco la nazione se non esiste
	---------------------------------------------------

	IF NOT dbo.LookupIstatNazioni(@Codice) IS NULL
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

	
	INSERT INTO IstatNazioni
		( Codice
		, Nome)
	VALUES
		( @Codice
		, @Nome)

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
    ON OBJECT::[dbo].[IstatNazioniInsert] TO [DataAccessDll]
    AS [dbo];

