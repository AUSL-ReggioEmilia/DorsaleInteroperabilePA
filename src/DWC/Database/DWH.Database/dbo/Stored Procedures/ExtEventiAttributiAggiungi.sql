


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	Aggiunge un attributo dell'evento identificato da @IdEsterno
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2018-07-13 - ETTORE: Uso della nuova funzione dbo.GetEventiPk
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Errore manca almeno un parametro obbligatorio..."
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiAttributiAggiungi]
(	
	@IdEsterno 	varchar (64),
	@Nome	varchar (64),
	@Valore	sql_variant
) AS
/* 
	Aggiungo un attributo all'evento
*/
	DECLARE @guidId			AS UNIQUEIDENTIFIER
	DECLARE @DataPartizione	AS SMALLDATETIME

	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	

	IF ISNULL(@IdEsterno, '') = '' OR ISNULL(@Nome, '') = '' OR @Valore IS NULL
		BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsterno, @Nome, @Valore)!', 16, 1)
		RETURN 1010
		END

	------------------------------------------------------
	--  Cerca IdEvento
	------------------------------------------------------	
	-- Legge la PK
	SELECT 
		@guidId = ID
		, @DataPartizione = DataPartizione
	FROM 
		[dbo].[GetEventiPk](@IdEsterno)


	IF Not @guidId IS NULL
		BEGIN
			BEGIN TRANSACTION

			INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
			SELECT Id, @Nome, @Valore, DataPartizione FROM store.EventiBase WHERE Id=@guidId

			IF @@ERROR <> 0 GOTO ERROR_EXIT

			---------------------------------------------------
			--     Completato
			---------------------------------------------------

			COMMIT
			SELECT INSERTED_COUNT=1
			RETURN 0
		END
	ELSE
		BEGIN
			---------------------------------------------------
			--     Referto non trovato
			---------------------------------------------------

			--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
			RAISERROR('Errore ''Evento'' non trovato!', 16, 1)
			RETURN 1002
		END	

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	SELECT INSERTED_COUNT=0
	RETURN 1

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiAttributiAggiungi] TO [ExecuteExt]
    AS [dbo];

