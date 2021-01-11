


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	
-- Modifica Ettore 2013-03-05: tolto riferimenti a RicoveriLog
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-06-25 - ETTORE: Aggiornamento dell'IdEsterno (=IdEsterno + DATA) cosi i successivi eventi sono sempre in inserimento
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a "Episodio non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiRicoveroRimuovi]
(
	@IdEsterno  varchar(64)
)
AS
BEGIN
	--
	-- ERASE -> Pone CodiceStato=2 (Cancellato) per tutti gli eventi dell'episodio
	--
	DECLARE @AziendaErogante				VARCHAR(16)
	DECLARE @SistemaErogante				VARCHAR(16)
	DECLARE @DataEventoErase		DATETIME
	DECLARE @NumeroNosologico		VARCHAR(64)
	DECLARE @NumRecord				INTEGER
	DECLARE @DataUltimoEventoErase		DATETIME

	SET NOCOUNT ON
	--
	-- Ricavo informazioni sull'evento di ERASE
	--
	SELECT 
		@AziendaErogante = AziendaErogante
		,@SistemaErogante = SistemaErogante
		,@DataEventoErase = DataModificaEsterno --DataEvento
		,@NumeroNosologico = NumeroNosologico
	FROM 
		store.EventiBase
	WHERE
		IdEsterno = @IdEsterno

	IF ISNULL(@NumeroNosologico,'')=''
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Episodio non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore ''Evento di erase'' non trovato!', 16, 1)
		RETURN 1002
	END

	--------------------------------------------------------------------------------------------------------
	-- Verifico se l'Erase corrente ha una DataModificaEsterno < di un record di Erase esistente
	--------------------------------------------------------------------------------------------------------
	SELECT 
		@DataUltimoEventoErase = MAX(DataModificaEsterno) --MAX(DataEvento)
	FROM 
		store.EventiBase
	WHERE
		IdEsterno <> @IdEsterno 
		AND AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		AND TipoEventoCodice = 'E'

	IF (NOT @DataUltimoEventoErase IS NULL) AND (@DataUltimoEventoErase > @DataEventoErase)
	BEGIN
		SELECT INSERTED_COUNT=NULL
		RETURN 1004 --Questo numero di viene controllato nel codice della DLL
	END

	--------------------------------------------------------------------------------------------------------
	-- Aggiorno i record dell'episodio: imposto StatoCodice=2 (Cancellato)
	-- In base all'ordine di inserimento dei record degli eventi questa potrebbe non aggiornare nulla
	--------------------------------------------------------------------------------------------------------
	DECLARE @PostFissoIdEsterno VARCHAR(64) = '@' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(24), GETDATE(), 121), '-', ''), ' ' , ''), ':',''), '.', '')
	UPDATE store.EventiBase
		SET StatoCodice = 2
			-- Modify date: 2019-06-25 - ETTORE: Aggiornamento dell'IdEsterno (=IdEsterno + DATA) cosi i successivi eventi sono sempre in inserimento
			, IdEsterno = IdEsterno + @PostFissoIdEsterno
	WHERE
		AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		--AND StatoCodice = 0 --eventi attivi
		--AND DataEvento < @DataEventoErase
		AND DataModificaEsterno < @DataEventoErase
		AND TipoEventoCodice IN ('A','T','D') 
		-- Modify date: 2019-06-25 - ETTORE: Aggiornamento dell'IdEsterno con nuovo valore: non aggiorno quelli già aggiornati!
		AND NOT IdEsterno LIKE ('%@%')  

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--     Completato
	-- Anche se non ho aggiornato nulla simulo aggiornamento avvenuto
	---------------------------------------------------
	SELECT INSERTED_COUNT = 1 --@NumRecord 
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	SELECT INSERTED_COUNT=0
	RETURN 1
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiRicoveroRimuovi] TO [ExecuteExt]
    AS [dbo];

