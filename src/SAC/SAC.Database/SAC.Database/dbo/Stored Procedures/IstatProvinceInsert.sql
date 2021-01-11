
CREATE PROCEDURE [dbo].[IstatProvinceInsert]
	  @Codice varchar(3)
	, @Nome varchar(64)
	, @Sigla varchar(2)
	, @CodiceRegione varchar(2)

AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inserisco la provincia se non esiste
	---------------------------------------------------

	IF NOT dbo.LookupIstatProvince(@Codice) IS NULL
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

	
	INSERT INTO IstatProvince
		( Codice
		, Nome
		, Sigla
		, CodiceRegione)
	VALUES
		( @Codice
		, @Nome
		, @Sigla
		, @CodiceRegione)

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
    ON OBJECT::[dbo].[IstatProvinceInsert] TO [DataAccessDll]
    AS [dbo];

