

CREATE PROCEDURE [dbo].[IstatComuniInsert]
(
	  @Codice varchar(6)
	, @Nome varchar(128)
	, @CodiceProvincia varchar(3)
	, @Provenienza VARCHAR(16) = NULL
	, @IdProvenienza VARCHAR(64) = NULL
)	
AS
BEGIN
/*
	MODIFICA ETTORE 2014-03-17: aggiunta la gestione dei campi Provenienza, IdProvenienza, DataAttivazione
*/
	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inserisco il comune se non esiste
	---------------------------------------------------

	IF NOT dbo.LookupIstatComuni(@Codice) IS NULL
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
	
	INSERT INTO IstatComuni
		( Codice
		, Nome
		, CodiceProvincia
		, Provenienza
		, IdProvenienza
		, DataInizioValidita
		)
	VALUES
		( @Codice
		, @Nome
		, @CodiceProvincia
		, @Provenienza
		, @IdProvenienza
		, '1800-01-01'
		)

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
    ON OBJECT::[dbo].[IstatComuniInsert] TO [DataAccessDll]
    AS [dbo];

