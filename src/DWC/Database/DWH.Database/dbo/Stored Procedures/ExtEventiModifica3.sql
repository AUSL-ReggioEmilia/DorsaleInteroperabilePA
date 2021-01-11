







-- =============================================
-- Author:		
-- Create date: 
-- Description:	Modifica un record di evento
-- Modify date: ETTORE 2017-09-20: Aggiungo attributo "AdtSpecchio_EventoProcessato"
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2018-07-13 - ETTORE: Uso della nuova funzione dbo.GetEventiPk
-- Modify date: 2019-02-25 SANDRO - Esclure da attributi XML quelli passati da parametro
-- Modify date: 2020-02-13 ETTORE - Modificato il messaggio dei campi obbligatori 
--									Se almeno un campo obbligatorio non è valorizzato si mostra 
--									i valori di tutti i campi obbligatori, valorizzati e non.
-- Modify date: 2020-02-24 ETTORE - HERO: Gestione della creazione del record evento di tipo LA per il collegamento Prenotazione-Ricovero
--										  Gestione aggiornamento attributo 'NumeroNosologico' nell'evento DL
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiModifica3]
(	
	@IdEsterno 				varchar (64),
	@IdPaziente				uniqueidentifier,
	@AziendaErogante 		varchar (16),
	@SistemaErogante 		varchar (16),
	@RepartoErogante 		varchar (64),
	@DataEvento 			datetime,
	@NumeroNosologico 		varchar (64),
	@TipoEventoCodice 		varchar (16) ,
    @TipoEventoDescr		varchar(128),
	@TipoEpisodio			varchar(16),
	@TipoEpisodioDescr		varchar(128), -- attributi
	@RepartoCodice	varchar (16),
	@RepartoDescr	varchar (128),
	@Diagnosi				varchar(1024),
	@XmlAttributi 			text = Null
) AS
BEGIN
/* 
Il campo @XmlAttributi deve avere la seguente struttura:
    <?xml version="1.0" encoding="iso-8859-1" ?>
    <Root>
	<Attributo Nome="CodiceSaub" Valore="3456677"/>
	<Attributo Nome="CodiceUSL" Valore="0034577"/>
    </Root>
Le date vanno convertite in stringa nel formato ISO8601 (yyyy-mm-ddThh:mm:ss.mmm)
*/

DECLARE @guidId AS uniqueidentifier
DECLARE @xmlDoc int
DECLARE @NumRecord int
DECLARE @IdReparto AS uniqueidentifier
DECLARE @DataPartizione as smalldatetime
DECLARE @Error INTEGER
--Per HERO
DECLARE @PrericoveroIdCodice VARCHAR(64)=NULL --contiene il nosologico della prenotazione associata al ricovero
DECLARE @PrericoveroIdCodice_OLD VARCHAR(64)=NULL

	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	
	IF ISNULL(@IdEsterno, '') = '' OR (@IdPaziente IS NULL)
			OR ISNULL(@AziendaErogante, '') = '' OR ISNULL(@SistemaErogante, '') = ''
			OR @DataEvento IS NULL
		BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		DECLARE @MsgParam VARCHAR(512) = 'Errore manca almeno un parametro obbligatorio. Valori dei parametri obbligatori: ' 
		SET @MsgParam = @MsgParam + ' @IdEsterno=' + ISNULL(@IdEsterno, 'NULL') + ','
		SET @MsgParam = @MsgParam + ' @IdPaziente=' + ISNULL(CAST(@IdPaziente AS VARCHAR(40)), 'NULL') + ','
		SET @MsgParam = @MsgParam + ' @AziendaErogante=' + ISNULL(@AziendaErogante, 'NULL') + ','
		SET @MsgParam = @MsgParam + ' @SistemaErogante=' + ISNULL(@SistemaErogante, 'NULL') + ','
		SET @MsgParam = @MsgParam + ' @DataEvento=' + ISNULL(CONVERT(VARCHAR(20), @DataEvento, 120), 'NULL') + ','
		SET @MsgParam = LEFT(@MsgParam , LEN(@MsgParam) - 1) + '.'
		RAISERROR(@MsgParam , 16, 1)
		RETURN 1010
		END

	-----------------------------------------------------------------------------------
	-- ADT SPECCHIO
	-- Verifico se esiste già un ricovero nel reparto identificato da @RepartoCodice
	-----------------------------------------------------------------------------------
	DECLARE @AdtSpecchio_EventoProcessato BIT = 0
	IF @TipoEventoCodice IN ('A','T') AND EXISTS( 
		select * from store.EventiBase where 
			AziendaErogante = RTRIM(@AziendaErogante)
			AND NumeroNosologico = RTRIM(@NumeroNosologico)
			AND TipoEventoCodice = @TipoEventoCodice 
			AND RepartoCodice = RTRIM(@RepartoCodice)
			AND DataEvento = @DataEvento 
		)
	BEGIN 
		SET @AdtSpecchio_EventoProcessato = 1
	END 
		
	------------------------------------------------------
	--  Cerca IdEvento e IdPaziente
	------------------------------------------------------	
	--SET @guidId = dbo.GetEventiId( @IdEsterno)
	-- Legge la PK e DataModificaEsterno 
	SELECT 
		@guidId = ID
		, @DataPartizione = DataPartizione
	FROM 
		[dbo].[GetEventiPk](@IdEsterno)


	IF NOT @guidId IS NULL
		BEGIN
			SET @NumRecord = 0
		
			SET NOCOUNT OFF	-- Per verificare se inserito
			
			SET @AziendaErogante = RTRIM(@AziendaErogante)
			SET @SistemaErogante = RTRIM(@SistemaErogante)
			SET @RepartoErogante = NULLIF(RTRIM(@RepartoErogante),'')	
			
			SET @NumeroNosologico = RTRIM(@NumeroNosologico)			
			SET @RepartoCodice = NULLIF(RTRIM(@RepartoCodice),'')		
			SET @RepartoDescr = NULLIF(RTRIM(@RepartoDescr),'')			
			SET @TipoEpisodio = NULLIF(RTRIM(@TipoEpisodio),'')			
			SET @Diagnosi = NULLIF(RTRIM(@Diagnosi),'')					

			BEGIN TRANSACTION
		------------------------------------------------------
		--  Aggiorno EventiBase
		------------------------------------------------------	

			UPDATE  store.EventiBase
			SET	IdPaziente=@IdPaziente,
				DataModifica=GetDate(),
				AziendaErogante=@AziendaErogante,
				SistemaErogante=@SistemaErogante,
				RepartoErogante=@RepartoErogante,
				DataEvento=@DataEvento,
				TipoEventoCodice = @TipoEventoCodice,
				TipoEventoDescr = @TipoEventoDescr, 
				NumeroNosologico = @NumeroNosologico,
				TipoEpisodio = @TipoEpisodio,
				RepartoCodice = @RepartoCodice,
				RepartoDescr = @RepartoDescr,
				Diagnosi = @Diagnosi
			WHERE 
				Id=@guidId

			SET @NumRecord = @@ROWCOUNT
			IF @NumRecord = 0 GOTO ERROR_EXIT
		
			SET NOCOUNT ON


		------------------------------------------------------------------------------------------------------------
		--  		Reparti richiedenti
		------------------------------------------------------------------------------------------------------------	
		IF NOT @RepartoCodice IS NULL
		BEGIN
			SELECT @IdReparto = RepartiRichiedentiSistemiEroganti.Id
			FROM dbo.RepartiRichiedentiSistemiEroganti WITH(NOLOCK) INNER JOIN dbo.SistemiEroganti WITH(NOLOCK)
				ON RepartiRichiedentiSistemiEroganti.IdSistemaErogante = dbo.SistemiEroganti.Id
			WHERE RepartiRichiedentiSistemiEroganti.RepartoRichiedenteCodice = RTRIM(@RepartoCodice) 
				AND SistemiEroganti.AziendaErogante = RTRIM(@AziendaErogante)
				AND SistemiEroganti.SistemaErogante = RTRIM(@SistemaErogante)

			--PRINT @IdReparto

			IF @IdReparto IS NULL
				--
				--  Nuovo
				--
				INSERT INTO dbo.RepartiRichiedentiSistemiEroganti
					(IdSistemaErogante, RepartoRichiedenteCodice, RepartoRichiedenteDescrizione)
				SELECT Id, RTRIM(@RepartoCodice), RTRIM(@RepartoDescr)
				FROM dbo.SistemiEroganti
				WHERE AziendaErogante = RTRIM(@AziendaErogante)
					AND SistemaErogante = RTRIM(@SistemaErogante)
			ELSE
				--
				--  Aggiorno 
				--
				UPDATE dbo.RepartiRichiedentiSistemiEroganti
				SET RepartoRichiedenteDescrizione = RTRIM(@RepartoDescr)
				WHERE Id = @IdReparto
					AND RepartoRichiedenteDescrizione <> RTRIM(@RepartoDescr)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		------------------------------------------------------------------------------------------------------------
		-- HERO
		------------------------------------------------------------------------------------------------------------
		-- HERO invia nell'attributo 'PrericoveroIdCodice' il nosologico della prenotaziopne associata all'accettazione
		-- Prima di cancellare gli attributi leggo se l'evento A che viene aggiornato aveva l'attributo PrericoveroIdCodice
		-- Se si allora questo nosologico è di HERO
		------------------------------------------------------------------------------------------------------------
		IF (@TipoEventoCodice='A')
		BEGIN
			SELECT 
				@PrericoveroIdCodice_OLD  = CAST(Valore AS varchar(64))
			FROM store.EventiAttributi AS EA
			WHERE 
				EA.IdEventiBase = @guidId
				AND EA.DataPartizione = @DataPartizione
				AND EA.Nome = 'PrericoveroIdCodice'
			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END 

		------------------------------------------------------------------------------------------------------------
		--  		Eventi Attributi
		------------------------------------------------------------------------------------------------------------	
			--
			-- Ricavo la DataPartizione dell'evento da usare nell'inserimento degli attributi
			--
			--SELECT @DataPartizione = Datapartizione FROM store.EventiBase where Id = @guidId
			
			---------------------------------------------------
			-- Rimuovo tutti gli attributi
			---------------------------------------------------
			DELETE FROM store.EventiAttributi WHERE IdEventiBase=@guidId
			
			IF @@ERROR <> 0 GOTO ERROR_EXIT

			---------------------------------------------------
			--     Attributi già in EventiBase: NESSUNO
			---------------------------------------------------
				
			---------------------------------------------------
			--     Attributi presenti solo in EventiAttributi:
			---------------------------------------------------
			IF LTRIM(RTRIM(@TipoEpisodioDescr))<>'' AND NOT @TipoEpisodioDescr IS NULL
				BEGIN
					INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
					VALUES (@guidId, 'TipoEpisodioDescr', LTRIM(RTRIM(@TipoEpisodioDescr)), @DataPartizione)

					IF @@ERROR <> 0 GOTO ERROR_EXIT
				END			
			---------------------------------------------------
			--     Altri Attributi: dati anagrafici ecc...
			---------------------------------------------------
			IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL 
				BEGIN 
					EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlAttributi

					INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
						SELECT @guidId, Nome, LTRIM(RTRIM(Valore)), @DataPartizione
						FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
							  WITH (Nome  varchar(64),
									Valore varchar(8000))
						WHERE LEN(Valore) > 0
							--
							-- Escludo attributo XML già passato come parametro o da processo
							--
							AND NOT Nome IN ('TipoEpisodioDescr', 'AdtSpecchio_EventoProcessato')

					SELECT @Error = @@ERROR
					IF @Error <> 0 GOTO REMOVE_DOC

					--
					-- HERO: Memorizzo il nosologico della lista di prenotazione
					-- Leggo l'attributo "PrericoveroIdCodice" che contiene il nosologico della Prenotazione
					IF (@TipoEventoCodice='A')
					BEGIN
						SELECT 
							@PrericoveroIdCodice = LTRIM(RTRIM(Valore)) 
						FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
							WITH (Nome  varchar(64),Valore varchar(8000))
						WHERE LEN(Valore) > 0 AND Nome = 'PrericoveroIdCodice'
					END 
					SELECT @Error = @@ERROR
					IF @Error <> 0 GOTO REMOVE_DOC

		REMOVE_DOC:
					EXEC sp_xml_removedocument @xmlDoc
					IF @Error <> 0 GOTO ERROR_EXIT

				END

			-----------------------------------------------------------------------------------
			-- ADT SPECCHIO
			-----------------------------------------------------------------------------------
			IF @AdtSpecchio_EventoProcessato = 1
			BEGIN 
				--
				-- Aggiungo l'attributo per segnalare all'orchestrazione all'ADT SPECCHIO che il ricovero in questo reparto era è già stato processato
				--
				INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
				VALUES (@guidId, 'AdtSpecchio_EventoProcessato', @AdtSpecchio_EventoProcessato, @DataPartizione)

				IF @@ERROR <> 0 GOTO ERROR_EXIT

			END 

			-----------------------------------------------------------------------------------
			--	HERO
			-----------------------------------------------------------------------------------
			--	Hero invia con l'accettazione il nosologico della lista di attesa associata (se esiste) al ricovero
			--	Creazione del record evento di tipo LA e inserimento attributo 'NumeroNosologico' nell'evento DL associato a tale ricovero
			--	Nella testata del record LA il numero nosologico è quello del ricovero
			--	L'attributo 'CodiceListaAttesa' del record LA è il nosologico della prenotazione
			-----------------------------------------------------------------------------------
			-- Solo se è una ACCETTAZIONE e @PrericoveroIdCodice della A è valorizzato (quindi il nosologico è di HERO) 
			-- oppure @PrericoveroIdCodice_OLD è valorizzato (quindi il nosologico è di HERO) 
			IF (@TipoEventoCodice='A') AND (ISNULL(@PrericoveroIdCodice, '') <> '' OR ISNULL(@PrericoveroIdCodice_OLD, '') <> '')
			BEGIN
				--
				-- Aggiorno al DL della lista di attesa collegata l'attributo 'NumeroNosologico' con valore @NumeroNosologico
				--
				EXECUTE dbo.ExtEventiListaAttesaDLAggiornaAttributoNumeroNosologico
					@guidId
					,@DataPartizione
					,@IdPaziente
					,@AziendaErogante
					,@SistemaErogante
					,@NumeroNosologico
					,@PrericoveroIdCodice
				IF @@ERROR <> 0 GOTO ERROR_EXIT

				--
				-- Aggiorno l'evento fittizio LA
				--
				EXECUTE dbo.ExtEventiListaAttesaCreaEventoLA
					@guidId
					,@DataPartizione
					,@IdPaziente
					,@AziendaErogante
					,@SistemaErogante
					,@RepartoErogante
					,@DataEvento
					,@TipoEpisodio
					,@RepartoCodice
					,@RepartoDescr
					,@Diagnosi
					,@NumeroNosologico
					,@PrericoveroIdCodice
				IF @@ERROR <> 0 GOTO ERROR_EXIT

			END 

			---------------------------------------------------
			--     Completato
			---------------------------------------------------
			COMMIT
			SELECT INSERTED_COUNT=@NumRecord
			RETURN 0
		END
	ELSE
		BEGIN
			---------------------------------------------------
			--     Evento non trovato
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
END














GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiModifica3] TO [ExecuteExt]
    AS [dbo];

