


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	
-- Modifica Ettore 2013-03-05: tolto riferimenti a RicoveriLog
-- Modifica Ettore 2016-10-13: l'evento X si dee comportare come un E
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-06-25 - ETTORE: Aggiornamento dell'IdEsterno (=IdEsterno + DATA) cosi i successivi eventi sono sempre in inserimento
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiRicoveroAnnulla]
(
	@IdEsterno  varchar(64)
)
AS
BEGIN
--
--	Pone CodiceStato=1 per tutti gli eventi di un episodio
--
	DECLARE @AziendaErogante				VARCHAR(16)
	DECLARE @SistemaErogante				VARCHAR(16)
	DECLARE @DataEventoAnnullamento			DATETIME
	DECLARE @NumeroNosologico				VARCHAR(64)
	DECLARE @NumRecord						INTEGER
	DECLARE @DataUltimoEventoAnnullamento	DATETIME

	SET NOCOUNT ON
	--
	-- Ricavo informazioni sull'evento di X di annullamento
	--
	SELECT 
		@AziendaErogante = AziendaErogante
		,@SistemaErogante = SistemaErogante
		,@DataEventoAnnullamento = DataModificaEsterno --DataEvento
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
		RAISERROR('Errore ''Evento di annullamento'' non trovato!', 16, 1)
		RETURN 1002
	END

	--------------------------------------------------------------------------------------------------------
	-- Verifico se l'Annullamento corrente ha una DataEvento < di un record di annullamento esistente
	--------------------------------------------------------------------------------------------------------
	SELECT 
		@DataUltimoEventoAnnullamento = MAX(DataModificaEsterno) -- MAX(DataEvento)
	FROM 
		store.EventiBase
	WHERE
		IdEsterno <> @IdEsterno 
		AND AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		AND TipoEventoCodice = 'X'

	IF (NOT @DataUltimoEventoAnnullamento IS NULL) AND (@DataUltimoEventoAnnullamento > @DataEventoAnnullamento)
	BEGIN
		SELECT INSERTED_COUNT=NULL
		RETURN 1004 --Questo numero di viene controllato nel codice della DLL
	END

	--------------------------------------------------------------------------------------------------------
	-- Aggiorno i record dell'episodio: imposto StatoCodice=1
	-- In base a come vengono inseriti i record l'update potrebbe aggiornare 0 record
	--------------------------------------------------------------------------------------------------------
	DECLARE @PostFissoIdEsterno VARCHAR(64) = '@' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(24), GETDATE(), 121), '-', ''), ' ' , ''), ':',''), '.', '')
	UPDATE store.EventiBase
		SET StatoCodice = 2					--Cancellato(E) --MODIFICA ETTORE 2016-10-13: l'evento X si deve comportare come l'evento E
			-- Modify date: 2019-06-25 - ETTORE: Aggiornamento dell'IdEsterno (=IdEsterno + DATA) cosi i successivi eventi sono sempre in inserimento
			, IdEsterno = IdEsterno + @PostFissoIdEsterno
	WHERE
		AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		--AND StatoCodice = 0 --eventi attivi: cosi mi rimangono gli stati ERASED
		--AND DataEvento < @DataEventoAnnullamento
		AND DataModificaEsterno < @DataEventoAnnullamento
		AND TipoEventoCodice IN ('A','T','D')
		-- Modify date: 2019-06-25 - ETTORE: Aggiornamento dell'IdEsterno con nuovo valore: non aggiorno quelli già aggiornati!
		AND NOT IdEsterno LIKE ('%@%')  

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--  Completato
	--  Simulo aggiornamento completato
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
    ON OBJECT::[dbo].[ExtEventiRicoveroAnnulla] TO [ExecuteExt]
    AS [dbo];

