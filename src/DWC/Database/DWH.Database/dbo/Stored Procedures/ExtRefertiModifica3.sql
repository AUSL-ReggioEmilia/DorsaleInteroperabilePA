









/*
	Modifica Ettore 2013-03-05: tolto i riferimenti a RefertiLog
	Modifica Ettore 2014-05-29: Gestione dei nuovi campi "DataEvento" DATETIME e "Firmato" BIT
		Tali campi vengono passati negli attributi (parametro @XmlAttributi) e devono essere scritti in testata nella tabella RefertiBase
		Se "DataEvento" è NULL la si valorizza con DataReferto
		Se "Firmato" è NULL lo si valorizza con 0
		Non inserisco negli attributi i campi DataEvento e Firmato

	MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]
	MODIFICA ETTORE 2016-11-18: Modificata la dimenzione del parametro @SpecialitaErogante da VARCHAR(16) a VARCHAR(64)	
	Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
	Modify date: 2019-02-25 SANDRO - Esclure da attributi XML quelli passati da parametro
	Modify date: 2019-06-12 ETTORE - Pulizia del nosologico per ecludere spazi, ritorni a capo  
	Modify date: 2019-06-26 ETTORE - Aumentato il campo @SezioneErogante a VARCHAR(64) (prima era VARCHAR(16))
    Modify date: 2020-02-13 ETTORE - Modificato il messaggio dei campi obbligatori 
									Se almeno un campo obbligatorio non è valorizzato si mostra 
									i valori di tutti i campi obbligatori, valorizzati e non.
	Modify date: 2020-05-21 ETTORE - Scadenza referto [ASMN 7291] e referto variato [ASMN 7758]
								   - leggo la tabella dei sistemi eroganti per numero versione e scadenza referto
								   - Non rimuovo gli attributi persistenti
								   - Cancella il contatore delle visualizzaioni
	Modify date: 2020-09-11 ETTORE - Modifica per raise dell'errore relativo a @StatoRichiestaCodice: eliminata la SELECT prima del RAISE ERROR
*/
CREATE PROCEDURE [dbo].[ExtRefertiModifica3]
(	@IdEsterno 				varchar (64),
	@IdPaziente				uniqueidentifier,
	@AziendaErogante 		varchar (16),
	@SistemaErogante 		varchar (16),
	@RepartoErogante 		varchar (64),
	@SezioneErogante 		varchar (64) ,	-- Attributo
	@SpecialitaErogante		varchar (64) , 	-- Attributo
	@DataReferto			datetime,
	@NumeroReferto 			varchar (16),
	@NumeroPrenotazione		varchar (32),	
	@NumeroNosologico 		varchar (64),
	@PrioritaCodice 		varchar (16), 	-- Attributo
	@PrioritaDescr 			varchar (128), 	-- Attributo
	@StatoRichiestaCodice 	varchar (16),
	@StatoRichiestaDescr 	varchar (128),	-- Attributo	
	@TipoRichiestaCodice	varchar (16),	-- Attributo
	@TipoRichiestaDescr 	varchar (128),	-- Attributo
	@RepartoRichiedenteCodice	varchar (16),	-- Attributo
	@RepartoRichiedenteDescr	varchar (128),	-- Attributo
	@MedicoRefertanteCodice	varchar (16), 	-- Attributo
	@MedicoRefertanteDescr	varchar (128), 	-- Attributo
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

	Le date vanno convertite in stringa nel formato ISO8601 (yyyy-mm-dd Thh:mm:ss.mmm)
*/

DECLARE @guidId AS uniqueidentifier
DECLARE @xmlDoc int
DECLARE @NumRecord int
DECLARE @Err int
DECLARE @IdRepartoRichiedente AS uniqueidentifier
DECLARE @ImportazioneStorica varchar(1) --valori 0/1
DECLARE @DataModifica Datetime
DECLARE @DataPartizione SmallDatetime

	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	
	IF ISNULL(@IdEsterno, '') = '' OR (@IdPaziente IS NULL)
		OR ISNULL(@AziendaErogante, '') = '' OR ISNULL(@SistemaErogante, '') = ''
		OR (@DataReferto IS NULL) 
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
		SET @MsgParam = @MsgParam + ' @DataReferto=' + ISNULL(CONVERT(VARCHAR(20), @DataReferto, 120), 'NULL') + ','
		SET @MsgParam = LEFT(@MsgParam , LEN(@MsgParam) - 1) + '.'
		RAISERROR(@MsgParam , 16, 1)
		RETURN 1010  -- il numero non ha importanza
	END

	IF NOT ISNULL(@StatoRichiestaCodice, '') IN ('', '0', '1', '2', '3')
	BEGIN
		------------------------------------------------------
		--Errore Stato Richiesta Codice
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore parametro StatoRichiestaCodice non valido!', 16, 1)
		RETURN 1000
	END

	------------------------------------------------------
	--Sistemazione valore reparto erogante
	------------------------------------------------------
	IF ISNULL(@RepartoErogante, '') = ''
	BEGIN
		SET @RepartoErogante = NULL
	END
		
	------------------------------------------------------
	--  Cerca IdReferto e IdPaziente
	------------------------------------------------------	

	-- Legge la PK del referto
	SELECT @guidId = ID, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsterno))
	
	IF NOT @guidId IS NULL
	BEGIN
		------------------------------------------------------
		-- Modifica per test su attributo "ImportazioneStorica" 
		------------------------------------------------------
		IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL
			-- Apro subito document xml
			EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlAttributi
				
		IF NOT @xmlDoc IS NULL
		BEGIN
			-- Leggo l'attributo "ImportazioneStorica" 
			SELECT 
				@ImportazioneStorica = LTRIM(RTRIM(Valore)) 
			FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
				WITH (Nome  varchar(64),Valore varchar(8000))
			WHERE LEN(Valore) > 0 AND Nome = 'ImportazioneStorica'
		END

		SET @ImportazioneStorica = ISNULL(@ImportazioneStorica,0)
		SET @DataModifica = GETDATE()

		IF @ImportazioneStorica = '1'
			SELECT @DataModifica = DataModifica FROM store.RefertiBase WHERE Id=@guidId
				
		------------------------------------------------------
		-- Modifica Ettore 2012-10-22: per scrivere IdOrderEntry in RefertiBase
		------------------------------------------------------
		DECLARE @IdOrderEntry VARCHAR(64)
		IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL
		BEGIN
			-- Leggo l'attributo "IdOrderEntry" 
			SELECT 
				@IdOrderEntry = LTRIM(RTRIM(Valore)) 
			FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
				WITH (Nome  varchar(64),Valore varchar(8000))
			WHERE LEN(Valore) > 0 AND Nome = 'IdOrderEntry'
		END
		SET @IdOrderEntry = NULLIF(@IdOrderEntry,'')
			
		------------------------------------------------------
		-- Modifica Ettore 2014-05-29: per scrivere DataEvento in RefertiBase
		------------------------------------------------------
		DECLARE @DataEvento DATETIME
		IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL
		BEGIN
			-- Leggo l'attributo "DataEvento" 
			SELECT 
				@DataEvento = CAST(LTRIM(RTRIM(Valore)) AS DATETIME)
			FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
				WITH (Nome  varchar(64),Valore varchar(8000))
			WHERE LEN(Valore) > 0 AND Nome = 'DataEvento'
		END
		SET @DataEvento = ISNULL(@DataEvento,@DataReferto)	
			
		------------------------------------------------------
		-- Modifica Ettore 2014-05-29: per scrivere Firmato in RefertiBase
		------------------------------------------------------
		DECLARE @Firmato BIT
		IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL
		BEGIN
			-- Leggo l'attributo "Firmato" 
			SELECT 
				@Firmato = CAST(LTRIM(RTRIM(Valore)) AS BIT)
			FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
				WITH (Nome  varchar(64),Valore varchar(8000))
			WHERE LEN(Valore) > 0 AND Nome = 'Firmato'
		END
		SET @Firmato = ISNULL(@Firmato,CAST(0 AS BIT))	

		------------------------------------------------------
		-- Pulizia del nosologico
		------------------------------------------------------
		IF NOT @NumeroNosologico IS NULL
			SET @NumeroNosologico = [dbo].[PulisceNosologico](@NumeroNosologico )

		------------------------------------------------------
		--Modify date: 2020-02-13 ETTORE - leggo la tabella dei sistemi eroganti
		------------------------------------------------------
		DECLARE @SistemiEroganti_RefertiFirmati BIT
		DECLARE @SistemiEroganti_@MassimaleDiScartoMesi INT
		SELECT 
			@SistemiEroganti_RefertiFirmati = RefertiFirmati 
			, @SistemiEroganti_@MassimaleDiScartoMesi = MassimaleDiScartoMesi 
		FROM SistemiEroganti WHERE AziendaErogante = @AziendaErogante AND SistemaErogante = @SistemaErogante 
			
		------------------------------------------------------
		--  		Referti Base
		------------------------------------------------------
						
		BEGIN TRANSACTION
				
		UPDATE [store].RefertiBase
		SET	IdPaziente=@IdPaziente,
			DataModifica=@DataModifica, --GetDate(),
			AziendaErogante=RTRIM(@AziendaErogante),
			SistemaErogante=RTRIM(@SistemaErogante),
			RepartoErogante=RTRIM(@RepartoErogante),
			DataReferto=@DataReferto,
			NumeroReferto=RTRIM(@NumeroReferto),
			NumeroPrenotazione=RTRIM(@NumeroPrenotazione),
			NumeroNosologico=@NumeroNosologico,
			StatoRichiestaCodice=CONVERT(TINYINT, ISNULL(@StatoRichiestaCodice, '')),
			RepartoRichiedenteCodice=RTRIM(@RepartoRichiedenteCodice),
			RepartoRichiedenteDescr=RTRIM(@RepartoRichiedenteDescr),
			IdOrderEntry = @IdOrderEntry,
			DataEvento = @DataEvento,
			Firmato = @Firmato
		WHERE Id=@guidId

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

		------------------------------------------------------------------------------------------------------------
		--  		Reparti richiedenti
		------------------------------------------------------------------------------------------------------------	

		SELECT @IdRepartoRichiedente = RepartiRichiedentiSistemiEroganti.Id
		FROM dbo.RepartiRichiedentiSistemiEroganti WITH(NOLOCK) INNER JOIN dbo.SistemiEroganti WITH(NOLOCK)
			ON RepartiRichiedentiSistemiEroganti.IdSistemaErogante = dbo.SistemiEroganti.Id
		WHERE RepartiRichiedentiSistemiEroganti.RepartoRichiedenteCodice = RTRIM(@RepartoRichiedenteCodice) 
			AND SistemiEroganti.AziendaErogante = RTRIM(@AziendaErogante)
			AND SistemiEroganti.SistemaErogante = RTRIM(@SistemaErogante)

		PRINT @IdRepartoRichiedente

		IF @IdRepartoRichiedente IS NULL
			--  Nuovo reparto

			INSERT INTO dbo.RepartiRichiedentiSistemiEroganti
				(IdSistemaErogante, RepartoRichiedenteCodice, RepartoRichiedenteDescrizione)
			SELECT Id, RTRIM(@RepartoRichiedenteCodice), RTRIM(@RepartoRichiedenteDescr)
			FROM dbo.SistemiEroganti
			WHERE AziendaErogante = RTRIM(@AziendaErogante)
				AND SistemaErogante = RTRIM(@SistemaErogante)
		ELSE
			--  Aggiorno reparto

			UPDATE dbo.RepartiRichiedentiSistemiEroganti
			SET RepartoRichiedenteDescrizione = RTRIM(@RepartoRichiedenteDescr)
			WHERE Id = @IdRepartoRichiedente
				AND RepartoRichiedenteDescrizione <> RTRIM(@RepartoRichiedenteDescr)

		IF @@ERROR <> 0 GOTO ERROR_EXIT

		------------------------------------------------------------------------------------------------------------
		--  		Rimuovo Attributi
		--	Modify date: 2020-02-13 ETTORE - non rimuovo gli attributi persistenti
		------------------------------------------------------------------------------------------------------------	
			 
		DELETE FROM [store].RefertiAttributi
		WHERE IdRefertiBase = @guidId
			AND DataPartizione = @DataPartizione
			AND NOT Nome LIKE '$@%'

		IF @@ERROR <> 0 GOTO ERROR_EXIT

		------------------------------------------------------------------------------------------------------------
		--  		Referti Attributi
		------------------------------------------------------------------------------------------------------------	
		
		IF LTRIM(RTRIM(@PrioritaCodice))<>'' AND NOT @PrioritaCodice IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'PrioritaCodice', LTRIM(RTRIM(@PrioritaCodice)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		IF LTRIM(RTRIM(@PrioritaDescr))<>'' AND NOT @PrioritaDescr IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'PrioritaDescr', LTRIM(RTRIM(@PrioritaDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		IF LTRIM(RTRIM(@MedicoRefertanteCodice))<>'' AND NOT @MedicoRefertanteCodice IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'MedicoRefertanteCodice', LTRIM(RTRIM(@MedicoRefertanteCodice)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		IF LTRIM(RTRIM(@MedicoRefertanteDescr))<>'' AND NOT @MedicoRefertanteDescr IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'MedicoRefertanteDescr', LTRIM(RTRIM(@MedicoRefertanteDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		
		IF LTRIM(RTRIM(@SezioneErogante))<>'' AND NOT @SezioneErogante IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'SezioneErogante', LTRIM(RTRIM(@SezioneErogante)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		
		IF LTRIM(RTRIM(@SpecialitaErogante))<>'' AND NOT @SpecialitaErogante IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'SpecialitaErogante', LTRIM(RTRIM(@SpecialitaErogante)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		
		IF LTRIM(RTRIM(@StatoRichiestaDescr))<>'' AND NOT @StatoRichiestaDescr IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'StatoRichiestaDescr', LTRIM(RTRIM(@StatoRichiestaDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
			
		IF LTRIM(RTRIM(@TipoRichiestaCodice))<>'' AND NOT @TipoRichiestaCodice IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'TipoRichiestaCodice', LTRIM(RTRIM(	@TipoRichiestaCodice)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
			
		IF LTRIM(RTRIM(@TipoRichiestaDescr))<>'' AND NOT @TipoRichiestaDescr IS NULL 
		BEGIN
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'TipoRichiestaDescr',	LTRIM(RTRIM(@TipoRichiestaDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		------------------------------------------------------
		--Modify date: 2020-02-13 ETTORE - Scadenza referto [ASMN 7291]: inserimento attributo 'DataMassimaleDiScarto'
		------------------------------------------------------
		IF NOT @SistemiEroganti_@MassimaleDiScartoMesi  IS NULL
		BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'DataMassimaleDiScarto', DATEADD(month, @SistemiEroganti_@MassimaleDiScartoMesi , @DataEvento)  , @DataPartizione)
		END

		------------------------------------------------------
		--Modify date: 2020-05-21 ETTORE - Referto variato [ASMN 7758]: inserimento attributo persistente $@NumeroVersione
		------------------------------------------------------
		IF (@Firmato = 1 AND @SistemiEroganti_RefertiFirmati = 1)
			OR 
			(@Firmato = 0 AND @SistemiEroganti_RefertiFirmati = 0 AND @StatoRichiestaCodice IN (1,2)) --COMPLETATO,VARIATO
		BEGIN
			--Leggo l'attributo di nome $@NumeroVersione e lo incremento di uno
			UPDATE [store].RefertiAttributi
				SET Valore = CAST(Valore AS INT) + 1
			WHERE IdRefertiBase = @guidId
				AND DataPartizione = @DataPartizione
				AND Nome = '$@NumeroVersione'
			--Se non ho aggiornato nulla devo inserire nuovo record dell'attributo
			IF @@ROWCOUNT = 0 
			BEGIN 
				INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
				VALUES (@guidId, '$@NumeroVersione', CAST(1 AS INT) , @DataPartizione)
			END
		END
		--Sia che abia aggiornato la versione che l'abbia inserita cancello eventuali visualizzaioni
		DELETE FROM [store].RefertiAttributi 
		WHERE IdRefertiBase = @guidId
			AND DataPartizione = @DataPartizione
			AND Nome like '$@Visualizzazioni@%'			--Cancello tutti gli attributi like '$@Visualizzaioni@%'
			AND NOT Nome like '$@Visualizzazioni@%@%'	--Non cancello il contatore delle singole versioni
		
		---------------------------------------------------
		--     Altri Attributi 
		---------------------------------------------------
		IF NOT @xmlDoc IS NULL
		BEGIN 
			INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
				SELECT @guidId, Nome, LTRIM(RTRIM(Valore)), @DataPartizione
				FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
						WITH (Nome  varchar(64),
							Valore varchar(8000))
				WHERE LEN(Valore) > 0
					--
					-- Escludo attributi che passano dal XML ma che salvo nella tabella
					-- manca IdOrderEntry un errore? NO. E'perchè non c'è nella testata degli schemi di output!
					-- Probabile che prima versione passasse solo da attributi per per compatibilità 
					--	sia rimasto
					--
					AND Nome NOT IN ('DataEvento','Firmato')
					--
					-- Escludo attributi che già arrivano via parametri
					--
					AND Nome NOT IN ('PrioritaCodice', 'PrioritaDescr'
									, 'MedicoRefertanteCodice', 'MedicoRefertanteDescr'
									, 'SezioneErogante', 'SpecialitaErogante'
									, 'StatoRichiestaDescr'
									, 'TipoRichiestaCodice', 'TipoRichiestaDescr')

			IF @@ERROR <> 0
			BEGIN
				EXEC sp_xml_removedocument @xmlDoc
				GOTO ERROR_EXIT
			END ELSE BEGIN
				EXEC sp_xml_removedocument @xmlDoc
			END
		END

		---------------------------------------------------
		--     Completato
		---------------------------------------------------

		COMMIT
		SELECT INSERTED_COUNT=@NumRecord
		RETURN 0

	END	ELSE BEGIN
		---------------------------------------------------
		--     Referto non trovato
		---------------------------------------------------
		--SELECT INSERTED_COUNT=NULL  --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('ExtRefertiModifica3: Errore referto non trovato!', 16, 1)
		RETURN 1002
	END	

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	
	IF NOT @xmlDoc IS NULL
		EXEC sp_xml_removedocument @xmlDoc
	
	IF @@TRANCOUNT > 0
		ROLLBACK

	SELECT INSERTED_COUNT=0
	RETURN 1
END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiModifica3] TO [ExecuteExt]
    AS [dbo];

