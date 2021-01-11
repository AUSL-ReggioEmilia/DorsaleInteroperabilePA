/* Aggiunge Prestazioni per sistemi di Laboratorio
MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetPrescrizioniPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]
*/
CREATE PROCEDURE [dbo].[ExtPrestazioniAggiungi2](
	@IdEsternoReferto 	varchar (64),
	@IdEsterno 		varchar (64),
	@DataErogazione 	datetime,
	@PrestazioneCodice 	varchar (12), 
	@PrestazioneDescrizione varchar (150), 
	@PrestazionePosizione 	int,		-- Attributo
	@SezioneCodice 		varchar (12),	
	@SezioneDescrizione 	varchar (255), 
	@SezionePosizione 	int,		-- Attributo
	@GravitaCodice 		varchar (16),	-- Attributo
	@GravitaDescrizione 	varchar (128),	-- Attributo
	@Quantita 		varchar (128),	-- Attributo
	@Risultato 		varchar (256),	-- Attributo
	@ValoriRiferimento 	varchar (256),	-- Attributo
	@PrestazioneCommenti 	varchar (2048),	-- Attributo
	@XmlAttributi 		text = Null
) AS
BEGIN
/* Aggiunge Prestazioni per sistemi di Laboratorio

Il campo @XmlAttributi deve avere la seguente struttura:
    <?xml version="1.0" encoding="iso-8859-1" ?>
    <Root>
	<Attributo Nome="CodiceSaub" Valore="3456677"/>
	<Attributo Nome="CodiceUSL" Valore="0034577"/>
    </Root>

Le date vanno convertite in stringa nel formato ISO8601 (yyyy-mm-dd Thh:mm:ss.mmm)
*/
DECLARE @IdRefertiBase uniqueidentifier
DECLARE @DataPartizione smalldatetime
DECLARE @NumRecord int
DECLARE @Err int

DECLARE @guidId as uniqueidentifier
DECLARE @xmlDoc int

	SET NOCOUNT ON

	-- Legge la PK del referto
	SELECT @IdRefertiBase = ID, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsternoReferto))

	IF @IdRefertiBase IS NULL
	BEGIN
		------------------------------------------------------
		--Errore se no referto
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore referto non trovato!', 16, 1)
		RETURN 1001
	END

	------------------------------------------------------
	--  		Prestazioni Base
	------------------------------------------------------	

	SET @guidId = NEWID() 

	BEGIN TRANSACTION

	INSERT INTO [store].[PrestazioniBase]
	(
		ID,
		DataPartizione,
		IdRefertiBase,
		IdEsterno,
		DataInserimento,
		DataModifica,
		DataErogazione,
		PrestazioneCodice,
		PrestazioneDescrizione,
		SoundexPrestazione,
		SezioneCodice,
		SezioneDescrizione, 
		SoundexSezione
	)
	VALUES
	(
		@guidId,
		@DataPartizione,
		@IdRefertiBase,
		@IdEsterno,
		GetDate(),
		GetDate(),
		@DataErogazione,
		RTRIM(@PrestazioneCodice),
		RTRIM(@PrestazioneDescrizione),
		SOUNDEX(@PrestazioneDescrizione),
		RTRIM(@SezioneCodice),
		RTRIM(@SezioneDescrizione), 
		SOUNDEX(@SezioneDescrizione)
	)

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

------------------------------------------------------
--  		Prestazioni Attributi
------------------------------------------------------
		
	IF LTRIM(RTRIM(@Quantita))<>'' AND NOT @Quantita IS NULL 
	BEGIN
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'Quantita', LTRIM(RTRIM(@Quantita)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@GravitaCodice))<>'' AND NOT @GravitaCodice IS NULL 
	BEGIN
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'GravitaCodice', LTRIM(RTRIM(@GravitaCodice)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@GravitaDescrizione))<>'' AND NOT @GravitaDescrizione IS NULL 
	BEGIN
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'GravitaDescrizione', LTRIM(RTRIM(@GravitaDescrizione)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@Risultato))<>'' AND NOT @Risultato IS NULL 
	BEGIN
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'Risultato', LTRIM(RTRIM(@Risultato)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@ValoriRiferimento))<>'' AND NOT @ValoriRiferimento IS NULL 
	BEGIN
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'ValoriRiferimento', LTRIM(RTRIM(@ValoriRiferimento)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END
	
	IF NOT @SezionePosizione IS NULL 
	BEGIN
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'SezionePosizione', @SezionePosizione, @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF NOT @PrestazionePosizione IS NULL 
	BEGIN
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'PrestazionePosizione', @PrestazionePosizione, @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	IF LTRIM(RTRIM(@PrestazioneCommenti))<>'' AND NOT @PrestazioneCommenti IS NULL 
	BEGIN	
		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
		VALUES (@guidId, 'Commenti', LTRIM(RTRIM(@PrestazioneCommenti)), @DataPartizione)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

---------------------------------------------------
--     Altri Attributi 
---------------------------------------------------

	IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL 
	BEGIN 
		EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlAttributi

		-- Execute a SELECT statement using OPENXML rowset provider.

		INSERT INTO [store].PrestazioniAttributi (IdPrestazioniBase, Nome,  Valore, DataPartizione) 
			SELECT @guidId, Nome, LTRIM(RTRIM(Valore)), @DataPartizione
			FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
					WITH (Nome  varchar(64),
						Valore varchar(8000))
			WHERE LEN(Valore) > 0

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

	IF @@TRANCOUNT > 0
		ROLLBACK
	
	SELECT INSERTED_COUNT=0
	RETURN 1
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPrestazioniAggiungi2] TO [ExecuteExt]
    AS [dbo];

