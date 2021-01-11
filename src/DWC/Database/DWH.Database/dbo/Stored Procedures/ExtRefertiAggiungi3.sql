



/*
	Modifica Ettore 2013-03-05: tolto i riferimenti a RefertiLog
	Modifica Ettore 2014-05-29: Gestione dei nuovi campi "DataEvento" DATETIME e "Firmato" BIT
		Tali campi vengono passati negli attributi (parametro @XmlAttributi) e devono essere scritti in testata nella tabella RefertiBase
		Se "DataEvento" è NULL la si valorizza con DataReferto
		Se "Firmato" è NULL lo si valorizza con 0
		Non inserisco negli attributi i campi DataEvento e Firmato

	MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetPrescrizioniPk()
								Usa la VIEW [Store]
	MODIFICA ETTORE 2016-11-18: Modificata la dimensione del parametro @SpecialitaErogante da VARCHAR(16) a VARCHAR(64)	

	Modify date: 2018-06-08 - ETTORE - Uso della funzione dbo.GetRefertiPK() al posto della dbo.GetRefertiId()
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
	Modify date: 2020-09-11 ETTORE - Modifica per raise dell'errore relativo a @StatoRichiestaCodice: eliminata la SELECT prima del RAISE ERROR
*/
CREATE PROCEDURE [dbo].[ExtRefertiAggiungi3] 
 (	@IdEsterno 					varchar (64),
	@IdPaziente					uniqueidentifier, --IdPaziente trovato nel SAC
	@AziendaErogante 			varchar (16),
	@SistemaErogante 			varchar (16),
	@RepartoErogante 			varchar (64),
	@SezioneErogante 			varchar (64) ,	-- Attributo
	@SpecialitaErogante			varchar (64) , 	-- Attributo
	@DataReferto				datetime,
	@NumeroReferto	 			varchar (16),
	@NumeroPrenotazione			varchar (32),	
	@NumeroNosologico			varchar (64),
	@PrioritaCodice				varchar (16), 	-- Attributo
	@PrioritaDescr 				varchar (128), 	-- Attributo
	@StatoRichiestaCodice 		varchar (16),
	@StatoRichiestaDescr 		varchar (128),	-- Attributo	
	@TipoRichiestaCodice		varchar (16),	-- Attributo
	@TipoRichiestaDescr 		varchar (128),	-- Attributo
	@RepartoRichiedenteCodice	varchar (16),	-- Attributo
	@RepartoRichiedenteDescr	varchar (128),	-- Attributo
	@MedicoRefertanteCodice		varchar (16), 	-- Attributo
	@MedicoRefertanteDescr 		varchar (128), 	-- Attributo
	@XmlAttributi 				text = Null
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

DECLARE @NumRecord int
DECLARE @Err int
DECLARE @DataPartizione  SmallDatetime
DECLARE @guidId uniqueidentifier

DECLARE @xmlDoc int

DECLARE @IdRepartoRichiedente uniqueidentifier
DECLARE @ImportazioneStorica varchar(1) --valori 0/1
DECLARE @DataInserimento  Datetime
DECLARE @DataModifica  Datetime

	SET NOCOUNT ON
	
	SET @DataPartizione = CONVERT(SmallDatetime, @DataReferto)

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
		--SELECT INSERTED_COUNT = NULL  --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore parametro StatoRichiestaCodice non valido! Valori permessi: '''', ''0'', ''1'', ''2'', ''3''', 16, 1)
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
	--  Cerco se esiste gia IdEsterno
	------------------------------------------------------	
	SELECT @guidId = ID FROM [dbo].[GetRefertiPk](RTRIM(@IdEsterno))
	IF NOT @guidId IS NULL
	BEGIN
		------------------------------------------------------
		--Errore se esiste referto
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('ExtRefertiAggiungi3: Errore il referto esiste già!', 16, 1)
		RETURN 1001
	END

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


		--Nuovo modo da testare
		--DECLARE @XML AS XML  = @XmlAttributi
		--SELECT @ImportazioneStorica = @XML.value('(/Root/Attributo[@Nome="ImportazioneStorica"]/@Valore)[1]', 'varchar(1)')
	END

	SET @ImportazioneStorica = ISNULL(@ImportazioneStorica,0)
	SET @DataInserimento = GETDATE()
	SET @DataModifica = GETDATE()

	IF @ImportazioneStorica = '1' 
	BEGIN
		SET @DataInserimento = @DataReferto
		SET @DataModifica = @DataReferto
	END
	
	------------------------------------------------------
	-- Modifica Ettore 2012-10-22: per scrivere IdOrderEntry in RefertiBase
	------------------------------------------------------
	DECLARE @IdOrderEntry VARCHAR(64)
	IF NOT @xmlDoc IS NULL
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
	IF NOT @xmlDoc IS NULL
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
	IF NOT @xmlDoc IS NULL
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
	--  Nuovo IdReferto
	------------------------------------------------------	

	SET @guidId = NEWID()
		
	BEGIN TRANSACTION
	
	------------------------------------------------------
	--  		Referti Base
	------------------------------------------------------	

	INSERT INTO [store].RefertiBase
	  (	
		Id,
		DataPartizione,
		IdEsterno,
		IdPaziente,
		DataInserimento,
		DataModifica,
		AziendaErogante,
		SistemaErogante,
		RepartoErogante,
		DataReferto,
		NumeroReferto,
		NumeroPrenotazione,
		NumeroNosologico,
		StatoRichiestaCodice,
		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr,
		Cancellato,
		DataModificaEsterno,
		IdOrderEntry,
		DataEvento,
		Firmato
	 )
	VALUES
	 (
		@guidId,
		@DataPartizione,
		@IdEsterno,
		@IdPaziente,		
		@DataInserimento,	
		@DataModifica,		
		RTRIM(@AziendaErogante),
		RTRIM(@SistemaErogante),
		RTRIM(@RepartoErogante),
		@DataReferto,
		RTRIM(@NumeroReferto),
		RTRIM(@NumeroPrenotazione),
		@NumeroNosologico, 
		CONVERT(TINYINT, ISNULL(@StatoRichiestaCodice, '')),
		RTRIM(@RepartoRichiedenteCodice),
		RTRIM(@RepartoRichiedenteDescr),
		0,
		NULL,
		@IdOrderEntry,
		@DataEvento,
		@Firmato
	 )

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
--  		Referti Attributi
------------------------------------------------------------------------------------------------------------	
	
	IF LTRIM(RTRIM(@PrioritaCodice))<>'' AND NOT @PrioritaCodice IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'PrioritaCodice', LTRIM(RTRIM(@PrioritaCodice)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@PrioritaDescr))<>'' AND NOT @PrioritaDescr IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'PrioritaDescr', LTRIM(RTRIM(@PrioritaDescr)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@MedicoRefertanteCodice))<>'' AND NOT @MedicoRefertanteCodice IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'MedicoRefertanteCodice', LTRIM(RTRIM(@MedicoRefertanteCodice)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@MedicoRefertanteDescr))<>'' AND NOT @MedicoRefertanteDescr IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'MedicoRefertanteDescr', LTRIM(RTRIM(@MedicoRefertanteDescr)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@SezioneErogante))<>'' AND NOT @SezioneErogante IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'SezioneErogante', LTRIM(RTRIM(@SezioneErogante)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@SpecialitaErogante))<>'' AND NOT @SpecialitaErogante IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'SpecialitaErogante', LTRIM(RTRIM(@SpecialitaErogante)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@StatoRichiestaDescr))<>'' AND NOT @StatoRichiestaDescr IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'StatoRichiestaDescr',	 LTRIM(RTRIM(@StatoRichiestaDescr)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@TipoRichiestaCodice))<>'' AND NOT @TipoRichiestaCodice IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@guidId, 'TipoRichiestaCodice', LTRIM(RTRIM(@TipoRichiestaCodice)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@TipoRichiestaDescr))<>'' AND NOT @TipoRichiestaDescr IS NULL
	BEGIN
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
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

	---------------------------------------------------
	--     Altri Attributi 
	---------------------------------------------------
	
	IF NOT @xmlDoc IS NULL
	BEGIN 
		-- Execute a SELECT statement using OPENXML rowset provider.
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
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
		--
		-- Nuovo modo per leggere XML senza sp_xml_preparedocument
		--
		--DECLARE @XML AS XML  = @XmlAttributi
		--SELECT Tab.Col.value('@Nome','varchar(64)') AS Nome,
		--		Tab.Col.value('@Valore','varchar(8000)') AS Valore
		--FROM @XML.nodes('/Root/Attributo') Tab(Col)
		--WHERE LEN(Tab.Col.value('@Valore','varchar(8000)')) > 0
		-- AND Tab.Col.value('@Nome','varchar(64)') NOT IN ('DataEvento','Firmato')

		IF @@ERROR <> 0
		BEGIN
			EXEC sp_xml_removedocument @xmlDoc
			GOTO ERROR_EXIT
		END	ELSE BEGIN
			EXEC sp_xml_removedocument @xmlDoc
		END
	END

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT
	SELECT INSERTED_COUNT=@NumRecord
	RETURN 0

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
    ON OBJECT::[dbo].[ExtRefertiAggiungi3] TO [ExecuteExt]
    AS [dbo];

