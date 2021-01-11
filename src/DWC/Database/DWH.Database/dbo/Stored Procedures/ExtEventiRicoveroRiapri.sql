

-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	
-- Modifica Ettore 2013-03-05: tolto riferimenti a RicoveriLog
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento di riapertura non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiRicoveroRiapri]
(
	@IdEsterno  varchar(64)
)
AS
BEGIN
	--
	--	Annullo tutte le dimissioni con DataEvento < @DataEvento di Riapertura -> CodiceStato=1
	--
	DECLARE @AziendaErogante				VARCHAR(16)
	DECLARE @SistemaErogante				VARCHAR(16)
	DECLARE @DataEventoRiapertura	DATETIME
	DECLARE @NumeroNosologico		VARCHAR(64)
	DECLARE @NumRecord				INTEGER
	DECLARE @DataUltimoEventoRiapertura	DATETIME

	SET NOCOUNT ON
	--
	-- Ricavo informazioni sull'evento di annullamento
	--
	SELECT 
		@AziendaErogante = AziendaErogante
		,@SistemaErogante = SistemaErogante
		,@DataEventoRiapertura = DataModificaEsterno --DataEvento
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
		RAISERROR('Errore ''Evento di riapertura'' non trovato!', 16, 1)
		RETURN 1002
	END

	--------------------------------------------------------------------------------------------------------
	-- Verifico se la Riapertura corrente ha una DataModificaEsterno < di un record di Riapertura esistente
	--------------------------------------------------------------------------------------------------------
	SELECT 
		@DataUltimoEventoRiapertura = MAX(DataModificaEsterno) -- MAX(DataEvento)
	FROM 
		store.EventiBase
	WHERE
		IdEsterno <> @IdEsterno 
		AND TipoEventoCodice = 'R'
		AND AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico

	IF (NOT @DataUltimoEventoRiapertura IS NULL) AND (@DataUltimoEventoRiapertura > @DataEventoRiapertura)
	BEGIN
		SELECT INSERTED_COUNT=NULL
		RETURN 1004 --Questo numero di viene controllato nel codice della DLL
	END


	--------------------------------------------------------------------------------------------------------
	-- Pongo StatoCodice = 1 per in tutti i record di dimissione con DataEvento < @DataEventoRiapertura
	-- che sono attivi
	-- Potrebbe arrivare il record di riapertura prima degli altri record? nel qual caso l'update aggiornerebbe
	-- zero record
	--------------------------------------------------------------------------------------------------------
	UPDATE store.EventiBase
		SET StatoCodice = 1	--Annullamento 
	WHERE 
		AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		AND StatoCodice = 0 -- solo eventi Dimissione attivi
		--AND DataEvento < @DataEventoRiapertura
		AND DataModificaEsterno < @DataEventoRiapertura
		AND TipoEventoCodice = 'D'

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	-- Simulo aggiornamento completato
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
    ON OBJECT::[dbo].[ExtEventiRicoveroRiapri] TO [ExecuteExt]
    AS [dbo];

