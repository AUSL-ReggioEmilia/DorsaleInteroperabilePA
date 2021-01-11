



-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	Aggiorna i dati anagrafici di tutti gli eventi della lista di attesa (a cui appartiene l'evento identificato da @IdEsterno) con i dati anagrafici presenti in @XmlAttributi
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo ai messaggi di errore:
--										"Manca almeno un parametro obbligatorio"
--										"Errore Evento lista di attesa SL non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiListaAttesaSpostamentoAnagrafico]
(
	@IdEsterno		varchar(64)  -- IdEsterno dell'evento SL
	,@XmlAttributi 	text=NULL	 -- Attributi anagrafici
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	--	Sostituisce in tutti gli eventi lista di attesa con stesso "codice" che sono associati all'evento
	--  con IdEsterno = @IdEsterno (= all'idesterno dell'evento SL) l'attuale IdPaziente con l'IdPaziente
	--  presente sul record di evento SL 
	--  Inoltre aggiorna gli attributi anagrafici del record IM con quelli presenti in @XmlAttributi
	--  che contiene solo i dati anagrafici del paziente
	--
	--  Non modifica l'IdPaziente del record fittizio LA per il quale dovrà arrivare una notifia di merge ADT (evento M)
	--  in quanto nel campo NumeroNosologico c'è scritto il vero nosologico associato alla lista di attesa
	--
	DECLARE @AziendaErogante	VARCHAR(16)
	DECLARE @SistemaErogante	VARCHAR(16)
	DECLARE @IdPazienteNew		UNIQUEIDENTIFIER
	DECLARE @CodiceListaAttesa	VARCHAR(64)
	DECLARE @xmlDoc				INTEGER
	DECLARE @IdEvento_SL		UNIQUEIDENTIFIER
	DECLARE @DataPartizione_SL	SMALLDATETIME
	
	DECLARE @IdEvento		UNIQUEIDENTIFIER	
	DECLARE @DataPartizioneEvento	SMALLDATETIME
	--
	--  Verifica parametri
	--
	IF ISNULL(@IdEsterno, '') = '' OR ISNULL(CAST(@XmlAttributi AS VARCHAR(10)), '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsterno, @XmlAttributi)!', 16, 1)
		RETURN 1010
	END
	--
	--- Ricavo informazioni sull'evento di SL
	--
	SELECT 
		@AziendaErogante = AziendaErogante
		, @SistemaErogante = SistemaErogante
		, @IdPazienteNew = IdPaziente
		, @CodiceListaAttesa = NumeroNosologico		-- leggo il codice della lista di attesa
		, @IdEvento_SL = Id							-- memorizzo Id dell'evento SL
		, @DataPartizione_SL = DataPartizione
	FROM 
		store.EventiBase
	WHERE
		IdEsterno = @IdEsterno

	IF (@IdEvento_SL IS NULL)
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Evento non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore ''Evento lista di attesa SL'' non trovato!', 16, 1)
		RETURN 1002
	END
	
	--
	-- 1) Memorizzo gli attributi presenti nel parametro @XmlAttributi in un tabella temporanea
	--    @XmlAttributi contiene solo gli attributi anagrafici
	--
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
	--
	-- Fino ad ora no ho apportato modifiche al database
	--
	BEGIN TRANSACTION	
	--
	-- 2) Salvo gli attributi anagrafici anche nel record SL: per sicurezza li cancello e poi li reinserisco
	--	dipende da quello che fa la data access - ora crea gli attributi anagrafici per tutti gli eventi
	--	
	-- Gli attributi anagrafici sono presenti su tutti gli eventi (non solo su IL)
	-- Cerco tutti gli eventi di IM e aggiorno gli attributi anagrafici in EventiAttributi 
	-- con quelli propri dell'evento di fusione
	--
	DECLARE curEventiIM CURSOR STATIC READ_ONLY
	FOR
	SELECT Id AS IdEvento, DataPartizione AS DataPartizioneEvento
	FROM store.EventiBase 
	WHERE AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante 
		AND NumeroNosologico = @CodiceListaAttesa
		--AND TipoEventoCodice = 'IL'
	OPEN curEventiIM
	FETCH NEXT FROM curEventiIM INTO @IdEvento , @DataPartizioneEvento
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			--------------------------------------------------------------------------------------------------------
			--- Cancello attributi anagrafici presenti
			--------------------------------------------------------------------------------------------------------
			DELETE FROM store.EventiAttributi
			WHERE IdEventiBase = @IdEvento
				AND Nome IN (SELECT TabAttributi.Nome FROM @TabAttributi AS TabAttributi)
		
			IF @@ERROR <> 0 GOTO ERROR_EXIT
		
			--------------------------------------------------------------------------------------------------------
			--- Inserisco i nuovi attributi anagrafici
			--------------------------------------------------------------------------------------------------------
			INSERT INTO store.EventiAttributi (IdEventiBase, Nome, Valore, DataPartizione)
			SELECT @IdEvento, TabAttributi.Nome, TabAttributi.Valore, @DataPartizioneEvento 
				FROM @TabAttributi AS TabAttributi

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		----------------------------------------------------------------------------------------------------------
		-- Prelevo IM successivo
		--------------------------------------------------------------------------------------------------------
		FETCH NEXT FROM curEventiIM INTO @IdEvento, @DataPartizioneEvento
	END --Fine WHILE

	--------------------------------------------------------------------------------------------------------
	-- Aggiorno l'IdPaziente per tutti gli eventi associati alla stessa lista di attesa
	--------------------------------------------------------------------------------------------------------
	UPDATE store.EventiBase
		SET IdPaziente = @IdPazienteNew
	WHERE
		AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @CodiceListaAttesa

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--     Completato
	---------------------------------------------------
	CLOSE curEventiIM
	DEALLOCATE curEventiIM

	COMMIT

	SELECT INSERTED_COUNT = 1
	RETURN 0

ERROR_EXIT:
	---------------------------------------------------
	--     Error
	---------------------------------------------------
	CLOSE curEventiIM
	DEALLOCATE curEventiIM

	ROLLBACK
	SELECT INSERTED_COUNT = 0
	RETURN 1

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiListaAttesaSpostamentoAnagrafico] TO [ExecuteExt]
    AS [dbo];

