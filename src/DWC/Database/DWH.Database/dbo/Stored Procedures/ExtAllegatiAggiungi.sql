
/* Aggiunge allegato al referto

MODIFICATO SANDRO 2015-08-19: Usa VIEW store
MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetPrescrizioniPk()
								Nella JOIN anche DataPartizione
MODIFICATO SANDRO 2019-02-20: Convertito il parametro @MimeData da IMAGE a VARBINARY(MAX)
							  Convertito il parametro @XmlAttributi da text a VARCHAR(MAX)
							  Salva dati del file negli attributi
MODIFICATO SANDRO 2019-05-13: Aggiunto filtro per Attributi in ingresso. Non inserisco attributi se generati dalla SP
MODIFICATO SANDRO 2020-09-01: Rimosso attributo calcolato 'FileChecksumBynary'
*/
CREATE PROCEDURE [dbo].[ExtAllegatiAggiungi](
	@IdEsternoReferto 	varchar(64),
	@IdEsterno 			varchar(64),
	@DataFile 			datetime,
	@NomeFile 			varchar(255),	-- Attributo
	@Descrizione 		varchar(255),	-- Attributo
	@Posizione 			int,			-- Attributo
	@StatoCodice 		varchar(16),	-- Attributo
	@StatoDescrizione 	varchar(128),	-- Attributo
	@MimeType 			varchar(50),
	@MimeData 			varbinary(max),
	@XmlAttributi 		varchar(max) = Null
) AS
BEGIN
/* Aggiunge allegato al referto
Il campo @XmlAttributi deve avere la seguente struttura:
    <?xml version="1.0" encoding="iso-8859-1" ?>
    <Root>
	<Attributo Nome="Codice1" Valore="3456677"/>
	<Attributo Nome="Codice2" Valore="0034577"/>
    </Root>

Le date vanno convertite in stringa nel formato ISO8601 (yyyy-mm-dd Thh:mm:ss.mmm)
*/
DECLARE @IdRefertiBase uniqueidentifier
DECLARE @DataPartizione smalldatetime
DECLARE @NumRecord integer
DECLARE @Err int
DECLARE @IdAllegatoBase uniqueidentifier

	SET NOCOUNT ON

	------------------------------------------------------
	-- Verifico che i byte dell'allegato siano presenti
	------------------------------------------------------
	IF ISNULL(DATALENGTH(@MimeData),0) = 0 
	BEGIN
		--------------------------------------------------------
		--- Simulo inserimento dell'allegato
		--------------------------------------------------------
		SELECT INSERTED_COUNT=1
		RETURN 0
	END

	-- Legge la PK del referto
	SELECT @IdRefertiBase = ID, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsternoReferto))
	
	IF @IdRefertiBase IS NULL
	BEGIN
		------------------------------------------------------
		--Errore se no paziente
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore referto non trovato!', 16, 1)
		RETURN 1001
	END

	---
	--- Cerca il ContentType dal nome del file
	---
	IF NULLIF(@MimeType, '') IS NULL AND NULLIF(@NomeFile, '') IS NOT NULL
		SET @MimeType = dbo.GetFileContentType( @NomeFile)

	IF NULLIF(@MimeType, '') IS NULL
		SET @MimeType = 'application'

	------------------------------------------------------
	-- Comprime MimeData
	-- Verifica se salvare l'originale o il compresso (dimensione)
	--
	--MimeStatoCompressione = 0; da processare
	--MimeStatoCompressione = 1; compreso da verificare
	--MimeStatoCompressione = 2; verificato, usa il compresso
	--MimeStatoCompressione = 3; verificato, usa l'originale
	------------------------------------------------------

	DECLARE @MimeDataOriginale AS VARBINARY(MAX) = @MimeData
	DECLARE @MimeDataCompresso AS VARBINARY(MAX) = NULL

	--Controllo se abilitata
	IF [dbo].[GetConfigurazioneInt]('Allegati','Compressione') = 1
		SET @MimeDataCompresso = dbo.compress(@MimeDataOriginale)

	-- Se non compresso salvo l'originale da riprocessare
	DECLARE @MimeStatoCompressione AS TINYINT = 0
	DECLARE @MimeDataChecksum AS INT = 0
	DECLARE @MimeDecompressoChecksum AS INT = 0

	DECLARE @MimeDataLength AS INT = 0
	DECLARE @MimeCompressoLength AS INT = 0
	DECLARE @MimeCompressoRatio AS REAL = 0

	SET @MimeDataChecksum = CHECKSUM(@MimeDataOriginale)
	SET @MimeDataLength = ISNULL(DATALENGTH(@MimeDataOriginale), 0)

	IF @MimeDataCompresso IS NOT NULL 
	BEGIN
		SET @MimeCompressoLength = DATALENGTH(@MimeDataCompresso)
		SET @MimeCompressoRatio = CONVERT(REAL, @MimeCompressoLength) / CONVERT(REAL, @MimeDataLength)

		SET @MimeDecompressoChecksum = CHECKSUM(dbo.decompress(@MimeDataCompresso))

		-- Verifica risultato e compressione 
		IF @MimeDataChecksum != @MimeDecompressoChecksum
		BEGIN
			-- Fallita la compressione
			SET @MimeStatoCompressione = 3
			SET @MimeDataCompresso = NULL
	
		END ELSE IF @MimeDataLength <= @MimeCompressoLength
		BEGIN
			-- Originale è più piccolo
			SET @MimeStatoCompressione = 3
			SET @MimeDataCompresso = NULL

		END	ELSE BEGIN
			-- Salvo il compresso
			SET @MimeStatoCompressione = 2
			SET @MimeDataOriginale = NULL
		END
	END
	------------------------------------------------------
	--- Aggiunge base
	------------------------------------------------------
	
	SET @IdAllegatoBase = NEWID() 

	BEGIN TRANSACTION

	INSERT INTO [store].AllegatiBase
	(
		ID,
		DataPartizione,
		IdRefertiBase,
		IdEsterno,
		DataInserimento,
		DataModifica,
		DataFile,
		MimeType,
		MimeData,
		MimeDataCompresso,
		MimeStatoCompressione,
		MimeDataOriginale
	)
	VALUES
	(
		@IdAllegatoBase,
		@DataPartizione,
		@IdRefertiBase,
		@IdEsterno,
		GETDATE(),
		GETDATE(),
		@DataFile,
		RTRIM(@MimeType),
		NULL,
		@MimeDataCompresso,
		@MimeStatoCompressione,
		@MimeDataOriginale
	)

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

------------------------------------------------------
--  		Allegato Attributi calcolati
------------------------------------------------------

	INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
	VALUES (@IdAllegatoBase, 'MimeCompressoRatio', @MimeCompressoRatio, @DataPartizione)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
	VALUES (@IdAllegatoBase, 'MimeDataLength', @MimeDataLength, @DataPartizione)

	IF @@ERROR <> 0 GOTO ERROR_EXIT
	
	INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
	VALUES (@IdAllegatoBase, 'FileChecksum', @MimeDataChecksum, @DataPartizione)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

------------------------------------------------------
--  		Allegato Attributi
------------------------------------------------------

	IF LTRIM(RTRIM(@NomeFile))<>'' AND NOT @NomeFile IS NULL 
	BEGIN
		INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
		VALUES (@IdAllegatoBase, 'NomeFile', LTRIM(RTRIM(@NomeFile)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@Descrizione))<>'' AND NOT @Descrizione IS NULL 
	BEGIN
		INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
		VALUES (@IdAllegatoBase, 'Descrizione', LTRIM(RTRIM(@Descrizione)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF NOT @Posizione IS NULL 
	BEGIN
		INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
		VALUES (@IdAllegatoBase, 'Posizione', @Posizione, @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@StatoCodice))<>'' AND NOT @StatoCodice IS NULL 
	BEGIN
		INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
		VALUES (@IdAllegatoBase, 'StatoCodice', LTRIM(RTRIM(@StatoCodice)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@StatoDescrizione))<>'' AND NOT @StatoDescrizione IS NULL 
	BEGIN
		INSERT INTO store.AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
		VALUES (@IdAllegatoBase, 'StatoDescrizione', LTRIM(RTRIM(@StatoDescrizione)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END
	
---------------------------------------------------
--     Altri Attributi 
---------------------------------------------------

	IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL 
	BEGIN 
		DECLARE @xml XML = CONVERT(XML, @XmlAttributi)

		INSERT INTO [store].AllegatiAttributi (IdAllegatiBase, Nome,  Valore, DataPartizione) 
		SELECT @IdAllegatoBase
				,Tab.Col.value('@Nome','varchar(64)') AS Nome
				,Tab.Col.value('@Valore','varchar(8000)') AS Valore
				,@DataPartizione
		FROM @XML.nodes('/Root/Attributo') Tab(Col)
		WHERE NOT Tab.Col.value('@Nome','varchar(64)')
			IN ('MimeCompressoRatio', 'MimeDataLength', 'FileChecksum'
				,'NomeFile', 'Descrizione', 'Posizione', 'StatoCodice', 'StatoDescrizione')

		IF @@ERROR <> 0 GOTO ERROR_EXIT
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

	IF @@TRANCOUNT > 0
		ROLLBACK

	SELECT INSERTED_COUNT=0
	RETURN 1
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtAllegatiAggiungi] TO [ExecuteExt]
    AS [dbo];

