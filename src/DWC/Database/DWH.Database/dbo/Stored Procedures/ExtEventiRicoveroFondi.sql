

-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	Modifica anagrafica del blocco di eventi del nosologico
-- Modifica Ettore 2013-03-05: tolto i riferimenti a RicoveriLog
-- Modifica Ettore 2013-06-03: ora gli attributi anagrafici vengono scritti in ogni evento e quindi devono essere sostituiti in ogni evento 
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore:
--										"Errore manca almeno un parametro obbligatorio..."
--										"Errore Paziente fuso non trovato"
--										"Errore Evento di fusione non trovato'
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiRicoveroFondi]
(
	@IdEsterno		varchar(64)  -- IdEsterno dell'evento di Fusione
	,@XmlAttributi 	text=NULL		 -- Attributi anagrafici
)
AS
BEGIN
	--
	--	Sostituisce in tutti gli eventi dell'episodio associato all'evento con IdEsterno = @IdEsterno,
	--	l'attuale IdPaziente con l'IdPaziente presente sul record evento di fusione
	--  Inoltre aggiorna gli attributi anagrafici dei record di evento dell'episodio con quelli 
	--  presenti in @XmlAttributi
	--
	--  @XmlAttributi contiene solo i dati anagrafici del paziente
	--
	DECLARE @AziendaErogante				VARCHAR(16)
	DECLARE @SistemaErogante				VARCHAR(16)
	DECLARE @IdEventoAccettazione		UNIQUEIDENTIFIER
	DECLARE @IdPazienteFuso		UNIQUEIDENTIFIER
	DECLARE @NumeroNosologico		VARCHAR(64)
	DECLARE @NumRecord				INTEGER
	DECLARE @DataModificaEsternoEventoFusione		DATETIME
	DECLARE @DataModificaEsternoUltimoEventoFusione		DATETIME
	DECLARE @xmlDoc int
	DECLARE @IdEventoFusione UNIQUEIDENTIFIER
	DECLARE @DataEventoFusione DATETIME
	DECLARE @DataPartizioneEventoFusione SMALLDATETIME --NUOVA
	DECLARE @DataPartizioneEventoAccettazione SMALLDATETIME --NUOVA

	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica parametri
	------------------------------------------------------	
	IF ISNULL(@IdEsterno, '') = '' OR ISNULL(CAST(@XmlAttributi AS VARCHAR(10)), '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsterno, @XmlAttributi)!', 16, 1)
		RETURN 1010
	END

	--------------------------------------------------------------------------------------------------------
	--- Ricavo informazioni sull'evento di FUSIONE
	--------------------------------------------------------------------------------------------------------
	SELECT 
		@AziendaErogante = AziendaErogante
		,@SistemaErogante = SistemaErogante
		,@IdPazienteFuso = IdPaziente
		,@DataModificaEsternoEventoFusione = DataModificaEsterno 
		,@NumeroNosologico = NumeroNosologico
		,@IdEventoFusione = Id --memorizzo Id dell'evento di fusione
		,@DataEventoFusione = DataEvento
		,@DataPartizioneEventoFusione = DataPartizione  --NUOVA
	FROM 
		store.EventiBase
	WHERE
		IdEsterno = @IdEsterno
		

	IF (ISNULL(@NumeroNosologico,'')='') OR (@IdEventoFusione IS NULL)
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Evento non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore ''Evento di fusione'' non trovato!', 16, 1)
		RETURN 1002
	END

	IF @IdPazienteFuso IS NULL
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Nuovo paziente non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore ''Paziente fuso'' non trovato!', 16, 1)
		RETURN 1001
	END

	--------------------------------------------------------------------------------------------------------
	--- Verifico che non esista un evento di fusione con data maggiore
	--- In questo caso la fusione non deve avvenire poichè i dati di fusione correnti sono obsoleti
	--- Esco dalla funzione simulando 
	--------------------------------------------------------------------------------------------------------
	SELECT 
		@DataModificaEsternoUltimoEventoFusione = MAX(DataModificaEsterno) 
	FROM 
		store.EventiBase
	WHERE
		IdEsterno <> @IdEsterno 
		AND TipoEventoCodice = 'M'
		AND AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico


	IF (NOT @DataModificaEsternoUltimoEventoFusione IS NULL) AND (@DataModificaEsternoUltimoEventoFusione > @DataModificaEsternoEventoFusione)
	BEGIN
		SELECT INSERTED_COUNT=NULL
		RETURN 1004 --Questo numero di viene controllato nel codice della DLL
	END
	
	--------------------------------------------------------------------------------------------------------
	--- 1) Memorizzo gli attributi presenti nel parametro @XmlAttributi in un tabella temporanea
	---    @XmlAttributi contiene solo gli attributi anagrafici
	--------------------------------------------------------------------------------------------------------
	EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlAttributi
	DECLARE @TabAttributi AS TABLE(Nome varchar(64), Valore varchar(8000))
	INSERT INTO @TabAttributi (Nome, Valore)
	SELECT Nome, LTRIM(RTRIM(Valore))
		FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
		WITH (Nome  varchar(64),
		Valore varchar(8000))
		WHERE LEN(Valore) > 0 
	IF @@ERROR <> 0
	BEGIN
		EXEC sp_xml_removedocument @xmlDoc
		RAISERROR('Errore durante preparazione del documento xml!', 16, 1)
		RETURN 1005
	END
	ELSE
	BEGIN
		EXEC sp_xml_removedocument @xmlDoc
	END
	--------------------------------------------------------------------------------------------------------
	--- 2) Poi li salvo negli attributi del record di fusione (NUOVA PARTE)
	--------------------------------------------------------------------------------------------------------
	DELETE FROM store.EventiAttributi
	WHERE IdEventiBase = @IdEventoFusione 
		AND Nome IN (SELECT TabAttributi.Nome FROM @TabAttributi AS TabAttributi)
	IF @@ERROR <> 0 GOTO ERROR_EXIT

	INSERT INTO store.EventiAttributi (IdEventiBase, Nome, Valore, DataPartizione)
	SELECT @IdEventoFusione, TabAttributi.Nome, TabAttributi.Valore, @DataPartizioneEventoFusione
		FROM @TabAttributi AS TabAttributi
	IF @@ERROR <> 0 GOTO ERROR_EXIT
	--------------------------------------------------------------------------------------------------------
	--- a questo punto gli attributi anagrafici sono presenti negli attributi associati all'evento di fusione
	--------------------------------------------------------------------------------------------------------

	--------------------------------------------------------------------------------------------------------
	--- Esecuzione della fusione degli eventi del nosologico che sono già presenti
	--------------------------------------------------------------------------------------------------------

	BEGIN TRANSACTION

	--------------------------------------------------------------------------------------------------------
	--- Cerco tutti gli eventi dell'episodio con data minore dell'evento di fusione 
	--- e aggiorno gli attributi anagrafici (in EventiAttributi) con quelli propri dell'evento di fusione
	--------------------------------------------------------------------------------------------------------
	DECLARE curEventi CURSOR STATIC READ_ONLY
	FOR
	SELECT Id AS IdEventoAccettazione, DataPartizione AS DataPartizioneEventoAccettazione
	FROM store.EventiBase 
	WHERE AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante --questo è sempre 'ADT'
		AND NumeroNosologico = @NumeroNosologico
		--AND TipoEventoCodice = 'A' --Modifica Ettore 2013-06-03: ora gli attributi anagrafici vengono scritti in ogni evento
		AND DataModificaEsterno < @DataModificaEsternoEventoFusione --aggiorno gli attributi delle accettazioni precedenti alla fusione

	OPEN curEventi
	FETCH NEXT FROM curEventi INTO @IdEventoAccettazione , @DataPartizioneEventoAccettazione
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			--------------------------------------------------------------------------------------------------------
			--- Cancello attributi anagrafici presenti
			--------------------------------------------------------------------------------------------------------
			DELETE FROM store.EventiAttributi
			WHERE IdEventiBase = @IdEventoAccettazione 
				AND Nome IN (SELECT TabAttributi.Nome FROM @TabAttributi AS TabAttributi)
			IF @@ERROR <> 0 GOTO ERROR_EXIT
			--------------------------------------------------------------------------------------------------------
			--- Inserisco i nuovi attributi anagrafici
			--------------------------------------------------------------------------------------------------------
			INSERT INTO store.EventiAttributi (IdEventiBase, Nome, Valore, DataPartizione)
			SELECT @IdEventoAccettazione, TabAttributi.Nome, TabAttributi.Valore, @DataPartizioneEventoAccettazione 
				FROM @TabAttributi AS TabAttributi

			IF @@ERROR <> 0 GOTO ERROR_EXIT

		END
		----------------------------------------------------------------------------------------------------------
		-- Prelevo evento successivo
		--------------------------------------------------------------------------------------------------------
		FETCH NEXT FROM curEventi INTO @IdEventoAccettazione , @DataPartizioneEventoAccettazione
	END --Fine WHILE

	--------------------------------------------------------------------------------------------------------
	-- Aggiorno l'IdPaziente per tutti gli eventi dell'episodio con data minore dell'evento di fusione
	--------------------------------------------------------------------------------------------------------
	UPDATE store.EventiBase
		SET IdPaziente = @IdPazienteFuso
	WHERE
		AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		AND DataModificaEsterno < @DataModificaEsternoEventoFusione

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--     Completato
	---------------------------------------------------
	CLOSE curEventi
	DEALLOCATE curEventi

	COMMIT

	SELECT INSERTED_COUNT= 1 --@NumRecord
	RETURN 0

ERROR_EXIT:
	---------------------------------------------------
	--     Error
	---------------------------------------------------
	CLOSE curEventi
	DEALLOCATE curEventi

	ROLLBACK
	SELECT INSERTED_COUNT=0
	RETURN 1

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiRicoveroFondi] TO [ExecuteExt]
    AS [dbo];

