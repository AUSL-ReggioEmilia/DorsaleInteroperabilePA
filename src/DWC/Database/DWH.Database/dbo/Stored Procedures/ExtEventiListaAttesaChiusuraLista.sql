







-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	
-- MODIFICA ETTORE 2015-02-24: aggiunto uso della funzione @@ERROR, prima c'era un TRY CATCH che mascherava errore dead lock
-- MODIFICA ETTORE 2016-12-15: migliorate le prestazioni di ricerca dell'evento LA aggiungendo il filtro per paziente
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2020-08-26 - ETTORE: Gestione per HERO
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento lista di attesa DL non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiListaAttesaChiusuraLista]
(
	@IdEsterno 	VARCHAR(64) --questo è l'IdEsterno dell'evento DL
)
AS
BEGIN
/*
	In seguito alla notifica DL esegue le seguenti operazioni:
	1) Cancella evento fittizio LA e i suoi attributi
	2) Se è presente il nosologico a cui è associata la lista di attesa crea record fittizio LA (con StatoCodice=1 - INVISIBILE)
		con NumeroNosologico = <nosologico a cui è associata la lista di attesa> e l'attributo 
		'CodiceListaAttesa' in cui è memorizzato il codice della lista di attesa 
		(per permettere il collegamento) fra "ricovero" e "prenotazione"
*/
	SET NOCOUNT ON;
	
	DECLARE @IdPazienteDL			uniqueidentifier
	DECLARE @AziendaEroganteDL 		varchar (16)
	DECLARE @SistemaEroganteDL 		varchar (16)
	DECLARE @RepartoEroganteDL 		varchar (64)
	DECLARE @DataEventoDL 			datetime
	DECLARE @NumeroNosologico 		varchar (64)  --vero numero nosologico
	DECLARE @TipoEpisodioDL			varchar(16)
	DECLARE @RepartoCodiceDL		varchar (16) 
	DECLARE @RepartoDescrDL			varchar (128) 
	DECLARE @DiagnosiDL				varchar(1024)
	DECLARE @CodiceListaAttesaDL	varchar(64)	--da mettere negli attributi
	DECLARE @IdEventoDL				uniqueidentifier
	DECLARE @DataPartizioneDL		smalldatetime
	DECLARE @DataModificaEsternoDL	datetime
	DECLARE @Error					integer

	SELECT 
		@IdEventoDL = Id
		, @IdPazienteDL = IdPaziente
		, @AziendaEroganteDL = AziendaErogante 		
		, @SistemaEroganteDL = SistemaErogante 		
		, @RepartoEroganteDL = RepartoErogante
		, @DataEventoDL = DataEvento
		, @CodiceListaAttesaDL  = NumeroNosologico --sull'evento DL il campo NumeroNosologico contiene il codice della lista di attesa
		, @TipoEpisodioDL = TipoEpisodio
		, @RepartoCodiceDL = RepartoCodice
		, @RepartoDescrDL = RepartoDescr
		, @DiagnosiDL = Diagnosi
		, @DataPartizioneDL = DataPartizione
		, @DataModificaEsternoDL = DataModificaEsterno
	FROM 
		store.EventiBase 
	WHERE 
		IdEsterno = @IdEsterno 
		
	IF @IdEventoDL IS NULL
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Evento DL non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore: Evento lista di attesa DL non trovato!', 16, 1)
		RETURN 1002
	END		
	
	BEGIN TRANSACTION
		--
		-- MODIFICA ETTORE 2016-12-15: calcolo tabella IdPaziente con tuti gli Id della catena di fusione
		--
		DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
		SELECT @IdPazienteAttivo = dbo.GetPazienteAttivoByIdSac(@IdPazienteDL)
		-- Lista dei fusi + l'attivo
		--
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		INSERT INTO @TablePazienti(Id)
			SELECT Id
			FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo)

		--
		-- Memorizzo Id del record fittizio LA e il suo nosologico
		-- Mi serve nel caso GST per cancellare LA e rifarlo, mentre nel caso HERO per capire se il nosologico è di HERO
		--
		DECLARE @IdEventoLA UNIQUEIDENTIFIER
		DECLARE @DataPartizioneEventoLA DATETIME
		DECLARE @AziendEroganteEventoLA VARCHAR(16)
		DECLARE @NumeroNosologicoEventoLA VARCHAR(64) --uguale al nosologico del ricovero associato alla prenotazione
		SELECT 
			@IdEventoLA = E.Id
			, @DataPartizioneEventoLA = E.DataPartizione
			, @AziendEroganteEventoLA = E.AziendaErogante
			, @NumeroNosologicoEventoLA = E.NumeroNosologico --nosologico del ricovero associato alla prenotazione con nosologicop uguale a 'CodiceListaAttesa'
		FROM store.EventiBase AS E 
			--Filtro paziente
			INNER JOIN @TablePazienti AS P
				ON E.IdPaziente = P.Id
			INNER JOIN store.EventiAttributi AS EA
				ON E.Id = EA.IdEventiBase And Nome = 'CodiceListaAttesa'
		WHERE AziendaErogante = @AziendaEroganteDL
				AND SistemaErogante = @SistemaEroganteDL
				AND TipoEventoCodice = 'LA'
				AND CAST(Valore AS VARCHAR(64)) = @CodiceListaAttesaDL

		--
		-- Per HERO: verifico se esiste un evento A che ha l'attributo 'PrericoveroIdCodice'
		--
		DECLARE @IdEventoA UNIQUEIDENTIFIER
		SELECT 
			@IdEventoA = E.Id
		FROM 
			store.EventiBase AS E 
			--Filtro paziente
			INNER JOIN @TablePazienti AS P
				ON E.IdPaziente = P.Id
			INNER JOIN store.EventiAttributi AS EA
				ON E.Id = EA.IdEventiBase And Nome = 'PrericoveroIdCodice'
		WHERE 
			E.AziendaErogante = @AziendEroganteEventoLA
			AND E.NumeroNosologico = @NumeroNosologicoEventoLA
			AND E.TipoEventoCodice = 'A'

		--
		-- Se @IdEventoLA esiste e @IdEventoA esiste (con l'attributo 'PrericoveroIdCodice') allora questo è un DL che viene da HERO
		-- Se NOT ((NOT @IdEventoLA IS NULL) AND (NOT @IdEventoA IS NULL)) è TRUE:
		--		1) DL è di GST: eseguo il codice successivo
		--		2) DL è di HERO e non è ancora arrivata la A (e quindi manca A e LA) e quindi anche se eseguo il codice successivo eseguo solo una cacnellazione di LA che non esiste -> OK
		-- Se NOT ((NOT @IdEventoLA IS NULL) AND (NOT @IdEventoA IS NULL)) è FALSE:
		--		1) DL è di HERO e poichè l'aggiornamento dell'evento DL ha cancellato gli attributi mi devo assicurare di riaggiungere l'attributo 'NumeroNosologico'
		--			contenente il nosologico del ricovero associato alla prenotazione.
		--
		IF NOT ((NOT @IdEventoLA IS NULL) AND (NOT @IdEventoA IS NULL))
		BEGIN 

			--
			-- Cancellazione di tutti gli attributi e dell'evento fittizio LA
			--
			DELETE FROM store.EventiAttributi 
			WHERE IdEventiBase = @IdEventoLA
					AND DataPartizione = @DataPartizioneEventoLA 
			SET @Error = @@ERROR
			IF @Error <> 0 GOTO ERROR_EXIT
				
			DELETE FROM store.EventiBase 
			WHERE Id = @IdEventoLA
					AND DataPartizione = @DataPartizioneEventoLA 
			SET @Error = @@ERROR
			IF @Error <> 0 GOTO ERROR_EXIT
				
			--
			-- Ricavo il numero nosologico associato alla lista di attesa con codice @CodiceListaAttesaDL:
			-- (il numero nosologico è il valore dell'attributo 'NumeroNosologico' dell'evento DL)
			--
			SELECT 
				@NumeroNosologico = CAST(Valore AS VARCHAR(64)) 
			FROM 
				store.EventiAttributi 
			WHERE 
				IdEventiBase = @IdEventoDL 
				AND Nome = 'NumeroNosologico' 
				AND DataPartizione = @DataPartizioneDL
					
			--
			-- Solo se ho il numero nosologico posso andare avanti: se il connettore legge un blocco DL, RL
			-- dopo che l'evento RL è già presente i dati del DL sono quelli dell'RL e il nosologico manca
			--
			IF ISNULL(@NumeroNosologico, '') <> ''
			BEGIN
				--
				-- Costruisco l'IdEsterno dell'evento LA
				--
				DECLARE @IdEsternoEventoLA VARCHAR(64)
				SET @IdEsternoEventoLA = @AziendaEroganteDL + '_' + @SistemaEroganteDL + '_' + @CodiceListaAttesaDL 
									+  REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(40), @DataModificaEsternoDL,121),'-',''), ' ', ''), ':',''), '.', '') 
									+ '_LA'
				------------------------------------------------------
				--  Inserisco il nuovo evento fittizio LA
				------------------------------------------------------	
				DECLARE @StatoCodiceLA INT
				SET @IdEventoLA = NEWID()
				SET @StatoCodiceLA = 0 --Lo imposto sempre VISIBILE
				INSERT INTO store.EventiBase
				  (	
					Id, IdEsterno, DataModificaEsterno, IdPaziente, DataInserimento, DataModifica, AziendaErogante, SistemaErogante, RepartoErogante
					, DataEvento, StatoCodice, TipoEventoCodice, TipoEventoDescr, NumeroNosologico,TipoEpisodio, RepartoCodice, RepartoDescr
					, Diagnosi, DataPartizione)
				VALUES
				 (
					@IdEventoLA, @IdEsternoEventoLA, @DataModificaEsternoDL, @IdPazienteDL,	GetDate(), GetDate(), @AziendaEroganteDL, @SistemaEroganteDL, @RepartoEroganteDL
					, @DataEventoDL, @StatoCodiceLA, 'LA', '', @NumeroNosologico, @TipoEpisodioDL, @RepartoCodiceDL, @RepartoDescrDL
					, @DiagnosiDL, @DataPartizioneDL
				 )	
				SET @Error = @@ERROR
				IF @Error <> 0 GOTO ERROR_EXIT
			 
				--
				-- Aggiungo tutti gli attributi dell'evento DL all'evento LA
				-- Prima li memorizzo in tabella temporanea (problema tabelle partizionate)
				--
				DECLARE @TempTblAttributi AS TABLE (Nome VARCHAR(64), Valore SQL_VARIANT, DataPartizione SMALLDATETIME)
				INSERT INTO @TempTblAttributi (Nome,  Valore, DataPartizione) 
				SELECT Nome,  Valore, @DataPartizioneDL 
				FROM store.EventiAttributi WHERE IdEventiBase = @IdEventoDL and DataPartizione = @DataPartizioneDL
				SET @Error = @@ERROR
				IF @Error <> 0 GOTO ERROR_EXIT
			
				--
				-- Inserimento attributi associati all'evento LA
				--
				INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
				SELECT @IdEventoLA, TAB.Nome, TAB.Valore, TAB.DataPartizione
				FROM @TempTblAttributi AS TAB
				--Aggiungo l'attributo che mi permette di ricavare dal nosologico la lista di attesa
				UNION 			
				SELECT @IdEventoLA, 'CodiceListaAttesa',  LTRIM(RTRIM(@CodiceListaAttesaDL)), @DataPartizioneDL 
				SET @Error = @@ERROR
				IF @Error <> 0 GOTO ERROR_EXIT
			
				--
				-- A questo punto creo un record in ricoveri base con StatoCodice=0 (Prenotazione) in attesa che venga sovrascritto 
				-- dall'arrivo della reale accettazione ADT. Verifico che non esista già un record per tale nosologico.
				--
				DECLARE @IdEsternoRicovero VARCHAR(64)
				SET @IdEsternoRicovero = @AziendaEroganteDL + '_' + @SistemaEroganteDL + '_' + @NumeroNosologico
				IF NOT EXISTS(SELECT * FROM store.RicoveriBase where IdEsterno = @IdEsternoRicovero)
				BEGIN
					DECLARE @IdRicovero UNIQUEIDENTIFIER
					DECLARE @StatoCodiceRicovero INT
					DECLARE @OspedaleCodice VARCHAR(16)
					DECLARE @OspedaleDesc VARCHAR(16)
					DECLARE @OspedaleDescr AS VARCHAR(128)
					DECLARE @TipoRicoveroCodice VARCHAR(16)
					DECLARE @TipoRicoveroDescr VARCHAR(128)
					SET @IdRicovero  = NEWID()
					--Inserisco il ricovero nello stato PRENOTAZIONE; poi verrà sovrascritto
					SET @StatoCodiceRicovero = 0 
					SET @OspedaleCodice = CONVERT(VARCHAR(16), dbo.GetEventiAttributo(@IdEventoDL, 'OspedaleCodice'))
					SET @OspedaleDesc = CONVERT(VARCHAR(128), dbo.GetEventiAttributo(@IdEventoDL, 'OspedaleDescr')) 
					SET @TipoRicoveroCodice = @TipoEpisodioDL
					SET @TipoRicoveroDescr = dbo.GetEventiTipoEpisodioDesc(NULL, @TipoEpisodioDL, CONVERT(VARCHAR(128), dbo.GetEventiAttributo(@IdEventoDL, 'TipoEpisodioDescr')))

					INSERT INTO store.RicoveriBase(Id, IdEsterno, DataModificaEsterno, DataInserimento, DataModifica
							   , StatoCodice, Cancellato, NumeroNosologico, AziendaErogante, SistemaErogante
							   , RepartoErogante, IdPaziente, OspedaleCodice, OspedaleDescr
							   , TipoRicoveroCodice, TipoRicoveroDescr, Diagnosi, DataAccettazione
							   , RepartoAccettazioneCodice, RepartoAccettazioneDescr
							   , DataTrasferimento, RepartoCodice, RepartoDescr, SettoreCodice, SettoreDescr, LettoCodice, DataDimissione
							   , DataPartizione)
					 VALUES(@IdRicovero, @IdEsternoRicovero, '1900-01-01', GETDATE(), GETDATE()
							   , @StatoCodiceRicovero ,0, @NumeroNosologico , @AziendaEroganteDL, @SistemaEroganteDL
							   , @RepartoEroganteDL, @IdPazienteDL, @OspedaleCodice, @OspedaleDesc 
							   , @TipoRicoveroCodice, @TipoRicoveroDescr, @DiagnosiDL , @DataEventoDL
							   , @RepartoCodiceDL , @RepartoDescrDL
							   , NULL, NULL, NULL, NULL, NULL, NULL, NULL
							   ,@DataPartizioneDL)
					SET @Error = @@ERROR
					IF @Error <> 0 GOTO ERROR_EXIT
					   
					--
					-- Aggiungo gli attributi dell'evento DL agli attributi del ricovero
					-- aggiungo solo quelli anagrafici...non ho le "Info di ricovero"!
					--
					INSERT INTO store.RicoveriAttributi (IdRicoveriBase, Nome, Valore, DataPartizione)
					SELECT @IdRicovero, TAB.Nome, TAB.Valore, TAB.DataPartizione
					FROM @TempTblAttributi AS TAB
					WHERE TAB.Nome IN ('CodiceAnagraficaCentrale','NomeAnagraficaCentrale','Cognome','Nome','Sesso'
								,'DataNascita','ComuneNascita','CodiceFiscale','CodiceSanitario','IdEsternoPaziente'
								)
					SET @Error = @@ERROR
					IF @Error <> 0 GOTO ERROR_EXIT
							
				END
			END
		END 
		ELSE
		BEGIN 
			--------------------------------------------------------------------------------
			-- L'evento DL riguarda un nosologico di HERO: Aggiornamento dell'attributo 'NumeroNosologico' dell'evento DL
			--------------------------------------------------------------------------------
			--
			-- Cancello l'attributo
			--
			DELETE FROM store.EventiAttributi
			WHERE IdEventiBase = @IdEventoDL
				AND DataPartizione = @DataPartizioneDL
				AND Nome = 'NumeroNosologico'

			SET @Error = @@ERROR
			IF @Error <> 0 GOTO ERROR_EXIT

			--
			-- Aggiungo l'attributo 'NumeroNosologico' all'evento DL se <> da '' o NULL
			-- L'evento LA per HERO viene creato nell'accettazione quindi uso la data partizione dell'evento A
			--
			IF ISNULL(@NumeroNosologicoEventoLA, '') <> ''
			BEGIN 
				INSERT INTO store.EventiAttributi(IdEventiBase,Nome,Valore,DataPartizione)
				VALUES(@IdEventoDL, 'NumeroNosologico', @NumeroNosologicoEventoLA, @DataPartizioneDL)

				SET @Error = @@ERROR
				IF @Error <> 0 GOTO ERROR_EXIT
			END 
			--------------------------------------------------------------------------------
			-- FINE Aggiornamento dell'attributo 'NumeroNosologico' dell'evento DL
			--------------------------------------------------------------------------------
		END
		--
		-- COMMIT
		--
		COMMIT 
		---------------------------------------------------
		--  Completato
		--  Simulo aggiornamento completato
		---------------------------------------------------
		SELECT INSERTED_COUNT = 1
		RETURN 0


ERROR_EXIT:	
		--
		-- ROLLBACK
		--
		IF @@TRANCOUNT > 0		
			ROLLBACK
		---------------------------------------------------
		--     Error
		---------------------------------------------------
		SELECT INSERTED_COUNT=0
		RETURN @Error
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiListaAttesaChiusuraLista] TO [ExecuteExt]
    AS [dbo];

