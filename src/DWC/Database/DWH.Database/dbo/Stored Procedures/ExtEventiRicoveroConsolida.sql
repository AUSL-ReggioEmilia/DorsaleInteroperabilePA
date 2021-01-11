


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	
-- Modifica Ettore 2013-03-05: tolto riferimenti a RicoveriLog
-- MODIFICA ETTORE 2016-10-16: L'evento X si comporta come l'evento E 
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiRicoveroConsolida]
(
	@IdEsterno  VARCHAR(64) --IdEsterno dell'evento
)
AS
BEGIN
/*
	Modifica Ettore 2013-03-05: tolto riferimenti a RicoveriLog
	MODIFICA ETTORE 2016-10-16: L'evento X si comporta come l'evento E 
*/
	--
	-- Questa funzione viene chiamata solo per eventi A,T,D
	--
	DECLARE @IdEvento			UNIQUEIDENTIFIER
	DECLARE @AziendaErogante	VARCHAR(16)
	DECLARE @SistemaErogante	VARCHAR(16)
	DECLARE @TipoEventoCodice	VARCHAR(16)
	DECLARE @DataEvento			DATETIME
	DECLARE @NumeroNosologico	VARCHAR(64)
	DECLARE @IdPaziente			UNIQUEIDENTIFIER
	DECLARE @NumRecord			INTEGER
	DECLARE @IdEventoFusione	UNIQUEIDENTIFIER
	DECLARE @IdPazienteFuso		UNIQUEIDENTIFIER
	DECLARE @DataModificaEsterno	DATETIME 
	DECLARE @DataPartizione		SMALLDATETIME
	
	-- 
	-- Fondamentale: Inizializzo a 1 questa variabile poichè potrebbe non essere eseguita 
	-- nessuna operazione di aggiornamento
	--
	SET @NumRecord = 1
	--
	-- Ricavo informazioni sull'evento corrente
	--
	SELECT 
		@IdEvento = Id
		,@AziendaErogante = AziendaErogante
		,@SistemaErogante = SistemaErogante
		,@IdPaziente = IdPaziente 
		,@TipoEventoCodice = TipoEventoCodice
		,@DataModificaEsterno = DataModificaEsterno 
		,@NumeroNosologico = NumeroNosologico
		,@DataEvento = DataEvento
		,@DataPartizione = DataPartizione
	FROM 
		store.EventiBase
	WHERE
		IdEsterno = @IdEsterno 

	IF ISNULL(@NumeroNosologico,'')='' 
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Evento non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore ''Evento'' non trovato!', 16, 1)
		RETURN 1002
	END

	SET NOCOUNT ON

	--------------------------------------------------------------------------------------------------------
	--- Se è una dimissione D -> verifico se è da Riaprire (deve esistere un R con DataModificaEsterna
	--- maggiore della DataModificaEsterna del D corrente
	--------------------------------------------------------------------------------------------------------
	IF @TipoEventoCodice = 'D'
	BEGIN
		DECLARE @DataModificaEsternoEventoRiapertura datetime
		SELECT 
			@DataModificaEsternoEventoRiapertura  = MAX(DataModificaEsterno)
		FROM store.EventiBase 
		WHERE 
			AziendaErogante = @AziendaErogante
			AND SistemaErogante = @SistemaErogante
			AND NumeroNosologico = @NumeroNosologico
			AND TipoEventoCodice = 'R'

		IF NOT @DataModificaEsternoEventoRiapertura IS NULL
		BEGIN
			IF @DataModificaEsterno < @DataModificaEsternoEventoRiapertura
			BEGIN
				UPDATE store.EventiBase
					SET StatoCodice = 1 --Annullato
				WHERE
					IdEsterno = @IdEsterno

				SET @NumRecord = @@ROWCOUNT
				IF @NumRecord = 0 GOTO ERROR_EXIT
			END
			ELSE
			BEGIN
				UPDATE store.EventiBase
					SET StatoCodice = 0 --lo rendo visibile
				WHERE
					IdEsterno = @IdEsterno
					AND StatoCodice = 1
				--Posso anche non aggiornare nessun record
			END
		END
		ELSE
		BEGIN
			-- INIZIO MODIFICA - 2009-09-01
			-- Debbo considerare la presenza di più record 'D': allora nascondo 
			-- i più vecchi rispetto al D corrente
			UPDATE store.Eventibase
				SET StatoCodice = 1 
			WHERE 
				StatoCodice = 0 
				AND AziendaErogante = @AziendaErogante
				AND SistemaErogante = @SistemaErogante
				AND NumeroNosologico = @NumeroNosologico
				AND TipoEventoCodice = 'D'
				AND DataModificaEsterno < @DataModificaEsterno
			-- FINE MODIFICA - 2009-09-01
		END
	END

	--------------------------------------------------------------------------------------------------------
	--- Per qualsiasi tipo di evento non di Azione
	--- Verifico se è da CANCELLARE/ERASE (se esiste un record E)
	--------------------------------------------------------------------------------------------------------
	DECLARE @DataModificaEsternoEventoErase datetime
	SELECT 
		@DataModificaEsternoEventoErase = MAX(DataModificaEsterno) 
	FROM store.EventiBase 
	WHERE 
		AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		--AND TipoEventoCodice IN = 'E'
		--MODIFICA ETTORE 2016-10-16: L'evento X si comporta come l'evento E 
		AND TipoEventoCodice IN ('E', 'X')

	IF NOT @DataModificaEsternoEventoErase IS NULL
	BEGIN
		IF @DataModificaEsterno < @DataModificaEsternoEventoErase
		BEGIN
			UPDATE store.EventiBase
				SET StatoCodice = 2 --Stato Cancellato
			WHERE
				IdEsterno = @IdEsterno

			SET @NumRecord = @@ROWCOUNT
			IF @NumRecord = 0 GOTO ERROR_EXIT
		END
		ELSE
		BEGIN
			-- INIZIO MODIFICA - 2009-09-01
			UPDATE store.EventiBase
				SET StatoCodice = 0 --Stato visibile
			WHERE
				IdEsterno = @IdEsterno

			SET @NumRecord = @@ROWCOUNT
			IF @NumRecord = 0 GOTO ERROR_EXIT
			-- FINE MODIFICA - 2009-09-01
		END
	END

	--------------------------------------------------------------------------------------------------------
	--- Verifico se è da FONDERE (se esiste un record M)
	--------------------------------------------------------------------------------------------------------
	DECLARE @DataModificaEsternoEventoFusione datetime
	--
	-- Prelevo ultimo evento di fusione (NUOVA MODIFICA 24/09/2009)
	--
	SELECT TOP 1
		@DataModificaEsternoEventoFusione = DataModificaEsterno,
		@IdEventoFusione = Id,
		@IdPazienteFuso = IdPaziente --ricavo qui l'id del paziente fuso
	FROM store.EventiBase 
	WHERE 
		AziendaErogante = @AziendaErogante
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
		AND TipoEventoCodice = 'M'
	ORDER BY DataModificaEsterno DESC

	IF (NOT @IdEventoFusione IS NULL) AND (NOT @DataModificaEsternoEventoFusione IS NULL)
	BEGIN
		IF @DataModificaEsterno < @DataModificaEsternoEventoFusione -- allora devo devo aggiornare
		BEGIN
			--
			-- Se l'evento è di Accettazione devo aggiornare i dati anagrafici presenti nei suoi attributi
			-- con i dati anagrafcici presenti negli attributi del record di fusione
			--
			IF @TipoEventoCodice = 'A'
			BEGIN
				--
				-- Cancello per l'evento A corrente (identificato da @IdEvento) tutti gli attributi anagrafici 
				--
				DELETE FROM store.EventiAttributi 
				WHERE IdEventiBase = @IdEvento
						AND Nome IN('CodiceAnagraficaCentrale',
								'NomeAnagraficaCentrale',
								'Cognome',
								'Nome',
								'Sesso',
								'DataNascita',
								'ComuneNascita',
								'CodiceFiscale',
								'CodiceSanitario')
								

				SET @NumRecord = @@ROWCOUNT
				IF @NumRecord = 0 GOTO ERROR_EXIT
				--
				-- Inserisco per l'evento corrente (identificato da @IdEvento) gli attributi anagrafici
				-- dell'evento di fusione (identificato da @IdEventoFusione)
				-- NON FUNZIONA SCRITTA IN QUAESTO MODO
				--INSERT INTO store.EventiAttributi (IdEventiBase, Nome, Valore, DataPartizione)
				--SELECT @IdEvento, Nome, CAST(Valore AS Varchar(8000)) , @DataPartizione
				--FROM store.EventiAttributi 
				--WHERE IdEventiBase = @IdEventoFusione
				--	  AND Nome IN('CodiceAnagraficaCentrale',
				--				'NomeAnagraficaCentrale',
				--				'Cognome',
				--				'Nome',
				--				'Sesso',
				--				'DataNascita',
				--				'ComuneNascita',
				--				'CodiceFiscale',
				--				'CodiceSanitario')
				--
				-- Carico i dati in una tabella temporanea
				--
				DECLARE @Temp AS TABLE(IdEventiBase uniqueidentifier, Nome varchar(649), Valore Varchar(8000))
				INSERT INTO @Temp (IdEventiBase, Nome, Valore)
				SELECT @IdEvento, Nome, CAST(Valore AS Varchar(8000))
				FROM store.EventiAttributi 
				WHERE IdEventiBase = @IdEventoFusione
						AND Nome IN('CodiceAnagraficaCentrale',
								'NomeAnagraficaCentrale',
								'Cognome',
								'Nome',
								'Sesso',
								'DataNascita',
								'ComuneNascita',
								'CodiceFiscale',
								'CodiceSanitario')
				SET @NumRecord = @@ROWCOUNT
				IF @NumRecord = 0 GOTO ERROR_EXIT
				--
				-- Li scrivo nel db usando la DataPartizione dell'evento corrente
				--				
				INSERT INTO store.EventiAttributi (IdEventiBase, Nome, Valore, DataPartizione)										
				SELECT IdEventiBase, Nome, Valore, @DataPartizione FROM @Temp AS TAB										

				SET @NumRecord = @@ROWCOUNT
				IF @NumRecord = 0 GOTO ERROR_EXIT

			END

			--
			-- Aggiorno l'id del paziente con il nuovo @IdPazienteFuso
			--
			UPDATE store.EventiBase
				SET IdPaziente = @IdPazienteFuso
			WHERE
				IdEsterno = @IdEsterno

			SET @NumRecord = @@ROWCOUNT
			IF @NumRecord = 0 GOTO ERROR_EXIT
		END
	END
			

	---------------------------------------------------
	--     Completato
	---------------------------------------------------
	SELECT INSERTED_COUNT=@NumRecord
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
    ON OBJECT::[dbo].[ExtEventiRicoveroConsolida] TO [ExecuteExt]
    AS [dbo];

