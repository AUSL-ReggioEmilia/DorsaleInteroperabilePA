


/*
	Modifica Ettore 2013-03-05: tolto riferimenti a RefertiLog
	Modifica Ettore 2014-05-29: Gestione dei nuovi campi "DataEvento" DATETIME e "Firmato" BIT
		Tali campi vengono passati negli attributi (parametro @XmlAttributi) e devono essere scritti in testata nella tabella RefertiBase
		Se "DataEvento" è NULL la si valorizza con DataReferto
		Se "Firmato" è NULL lo si valorizza con 0
		Non inserisco negli attributi i campi DataEvento e Firmato
		
MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]

	Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
*/
CREATE PROCEDURE [dbo].[ExtRefertiModifica2]
(	@IdEsterno 		varchar (64),
	@IdEsternoPaziente	varchar (64),
	@AziendaErogante 	varchar (16),
	@SistemaErogante 	varchar (16),
	@RepartoErogante 	varchar (64),
	@SezioneErogante 	varchar (16) ,	-- Attributo
	@SpecialitaErogante 	varchar (16) , 	-- Attributo
	@DataReferto		datetime,
	@NumeroReferto 	varchar (16),
	@NumeroPrenotazione 	varchar (32),	
	@NumeroNosologico 	varchar (10),
	@PrioritaCodice 		varchar (16), 	-- Attributo
	@PrioritaDescr 		varchar (128), 	-- Attributo
	@StatoRichiestaCodice 	varchar (16),
	@StatoRichiestaDescr 	varchar (128),	-- Attributo	
	@TipoRichiestaCodice	varchar (16),	-- Attributo
	@TipoRichiestaDescr 	varchar (128),	-- Attributo
	@RepartoRichiedenteCodice	varchar (16),	-- Attributo
	@RepartoRichiedenteDescr	varchar (128),	-- Attributo
	@MedicoRefertanteCodice	varchar (16), 	-- Attributo
	@MedicoRefertanteDescr	varchar (128), 	-- Attributo
	@XmlAttributi 		text = Null
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
DECLARE @IdPaziente AS uniqueidentifier
DECLARE @xmlDoc int
DECLARE @NumRecord int
DECLARE @Err int
DECLARE @IdRepartoRichiedente uniqueidentifier
DECLARE @ImportazioneStorica varchar(1) --valori 0/1
DECLARE @DataModifica Datetime
DECLARE @DataPartizione SmallDatetime

	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	
		
	IF ISNULL(@IdEsterno, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsterno)!', 16, 1)
		RETURN 1010
	END

	IF ISNULL(@IdEsternoPaziente, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsternoPaziente)!', 16, 1)
		RETURN 1011
	END

	IF ISNULL(@AziendaErogante, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@AziendaErogante)!', 16, 1)
		RETURN 1012
	END

	IF ISNULL(@SistemaErogante, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@SistemaErogante)!', 16, 1)
		RETURN 1013
	END

	IF ISNULL(@RepartoErogante, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL
		--RAISERROR('Errore manca almeno un parametro obbligatorio (@RepartoErogante)!', 16, 1)
		--RETURN 1014
		SET @RepartoErogante = NULL
	END

	IF @DataReferto IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@DataReferto)!', 16, 1)
		RETURN 1015
	END

	IF NOT ISNULL(@StatoRichiestaCodice, '') IN ('', '0', '1', '2', '3')
	BEGIN
		------------------------------------------------------
		--Errore Stato Richiesta Codice
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore parametro StatoRichiestaCodice non valido!', 16, 1)
		RETURN 1000
	END
		
	------------------------------------------------------
	--  Cerca IdPaziente
	------------------------------------------------------	

	IF @IdEsternoPaziente = '00000000-0000-0000-0000-000000000000'
		SET @IdPaziente = CAST(@IdEsternoPaziente AS UNIQUEIDENTIFIER)
	ELSE
		SET @IdPaziente = dbo.GetPazientiIdByDipartimento(@IdEsternoPaziente)
	
	IF @IdPaziente IS NULL
	BEGIN
		------------------------------------------------------
		--Errore se no paziente
		------------------------------------------------------
		SELECT INSERTED_COUNT=NULL
		RAISERROR('Errore paziente non trovato!', 16, 1)
		RETURN 1001
	END

	------------------------------------------------------
	--  Cerca IdReferto
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
			NumeroNosologico=RTRIM(@NumeroNosologico),
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
		------------------------------------------------------------------------------------------------------------	

		DELETE FROM [store].RefertiAttributi
		WHERE IdRefertiBase = @guidId
			AND DataPartizione = @DataPartizione
		
		IF @@ERROR <> 0 GOTO ERROR_EXIT

		------------------------------------------------------------------------------------------------------------
		--  		Referti Attributi
		------------------------------------------------------------------------------------------------------------	
		
		IF LTRIM(RTRIM(@PrioritaCodice))<>'' AND NOT @PrioritaCodice IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'PrioritaCodice', LTRIM(RTRIM(@PrioritaCodice)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		IF LTRIM(RTRIM(@PrioritaDescr))<>'' AND NOT @PrioritaDescr IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'PrioritaDescr', LTRIM(RTRIM(@PrioritaDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		IF LTRIM(RTRIM(@MedicoRefertanteCodice))<>'' AND NOT @MedicoRefertanteCodice IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'MedicoRefertanteCodice', LTRIM(RTRIM(@MedicoRefertanteCodice)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		IF LTRIM(RTRIM(@MedicoRefertanteDescr))<>'' AND NOT @MedicoRefertanteDescr IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'MedicoRefertanteDescr', LTRIM(RTRIM(@MedicoRefertanteDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		
		IF LTRIM(RTRIM(@SezioneErogante))<>'' AND NOT @SezioneErogante IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'SezioneErogante', LTRIM(RTRIM(@SezioneErogante)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		
		IF LTRIM(RTRIM(@SpecialitaErogante))<>'' AND NOT @SpecialitaErogante IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'SpecialitaErogante', LTRIM(RTRIM(@SpecialitaErogante)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		
		IF LTRIM(RTRIM(@StatoRichiestaDescr))<>'' AND NOT @StatoRichiestaDescr IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'StatoRichiestaDescr', LTRIM(RTRIM(@StatoRichiestaDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
			
		IF LTRIM(RTRIM(@TipoRichiestaCodice))<>'' AND NOT @TipoRichiestaCodice IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'TipoRichiestaCodice', LTRIM(RTRIM(@TipoRichiestaCodice)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
			
		IF LTRIM(RTRIM(@TipoRichiestaDescr))<>'' AND NOT @TipoRichiestaDescr IS NULL 
		BEGIN
			INSERT INTO  [store].RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@guidId, 'TipoRichiestaDescr',	LTRIM(RTRIM(@TipoRichiestaDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END
		
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
				WHERE LEN(Valore) > 0 AND Nome NOT IN ('DataEvento','Firmato')

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

	END	ELSE BEGIN

		---------------------------------------------------
		--     Referto non trovato
		---------------------------------------------------

		SELECT INSERTED_COUNT=NULL
		RAISERROR('Errore referto non trovato!', 16, 1)
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
    ON OBJECT::[dbo].[ExtRefertiModifica2] TO [ExecuteExt]
    AS [dbo];

