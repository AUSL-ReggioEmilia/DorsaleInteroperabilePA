
CREATE PROCEDURE [dbo].[IstatAslInsert]
	  @Codice varchar(6)
	, @CodiceComune varchar(6)
	, @Nome varchar(64)
	, @CodiceAslRegione varchar(3)

AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inserisco asl se non esiste
	---------------------------------------------------

	IF NOT dbo.LookupIstatAsl(@Codice, @CodiceComune) IS NULL
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

	
	INSERT INTO IstatAsl
		( Codice
		, CodiceComune
		, Nome
		, CodiceAslRegione)
	VALUES
		( @Codice
		, @CodiceComune
		, @Nome
		, @CodiceAslRegione)

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
    ON OBJECT::[dbo].[IstatAslInsert] TO [DataAccessDll]
    AS [dbo];

