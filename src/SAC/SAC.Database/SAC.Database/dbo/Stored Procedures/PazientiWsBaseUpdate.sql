



-- =============================================
-- Creation date: ???
-- Author: ???
-- Modify date: 29/09/2011
-- Modify date: 2014-10-22: ETTORE: Eseguito test quando si cerca IdPaziente per [Provenienza,IdProvenienza]. Se paziente non trovato si genera errore.
--									Aggiunto il test "IF @@TRANCOUNT > 0" prima di fare il rollback
-- Modify date: 2016-07-22: ETTORE: Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
-- Description: aggiunto il controllo del parametro @IdProvenienza e @Id
-- Modify date: 2019-11-06: ETTORE: Riattivazione anagrafiche cancellate logicamente [ASMN-4052]
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsBaseUpdate]
	  @Utente AS varchar(64)

	, @Id uniqueidentifier
	, @Provenienza varchar(16)
	, @IdProvenienza varchar(64)
	, @Tessera varchar(16)
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @Sesso varchar(1)
	, @ComuneNascitaCodice varchar(6)
	, @NazionalitaCodice varchar(3)
	, @CodiceFiscale varchar(16)
	
	, @ComuneResCodice varchar(6)
	, @SubComuneRes varchar(64)
	, @IndirizzoRes varchar(256)
	, @LocalitaRes varchar(128)
	, @CapRes varchar(8)

	, @ComuneDomCodice varchar(6)
	, @SubComuneDom varchar(64)
	, @IndirizzoDom varchar(256)
	, @LocalitaDom varchar(128)
	, @CapDom varchar(8)
	
	, @IndirizzoRecapito varchar(256)
	, @LocalitaRecapito varchar(128)
	, @Telefono1 varchar(20)
	, @Telefono2 varchar(20)
	, @Telefono3 varchar(20)

AS
BEGIN

DECLARE @LivelloAttendibilita AS tinyint
DECLARE @LivelloAttendibilitaCorrente AS tinyint

DECLARE @MsgEvento AS varchar(250)
DECLARE @MsgIstat AS varchar(64)
DECLARE @Msg AS varchar(500)

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo provenienza da utente
	---------------------------------------------------
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore durante PazientiWsBaseUpdate, il campo Provenienza è vuoto!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Controlla livello attendibilità; Aggiorna solo se pari o maggiore
	---------------------------------------------------	
	IF @Id IS NULL
		BEGIN
			IF @IdProvenienza IS NULL
			BEGIN
				RAISERROR('Errore durante PazientiWsBaseUpdate, il campo IdProvenienza è vuoto!', 16, 1)
				SELECT 2001 AS ERROR_CODE
				GOTO ERROR_EXIT
			END
			--
			-- Cerco il paziente e il livello di attendibilità per Provenienza, IdProvenienza
			--
			SELECT @Id = Id, @LivelloAttendibilitaCorrente = LivelloAttendibilita
			FROM Pazienti 
			WHERE Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza
			--
			-- Verifico se ho trovato il record, altrimenti genero errore
			--
			IF @Id IS NULL
			BEGIN
				RAISERROR('Errore durante PazientiWsBaseUpdate, paziente non trovato per Provenienza e IdProvenienza!', 16, 1)
				SELECT 2001 AS ERROR_CODE
				GOTO ERROR_EXIT
			END
		END
	ELSE
		BEGIN
			IF @Id IS NULL
			BEGIN
				RAISERROR('Errore durante PazientiWsBaseUpdate, il campo Id è vuoto!', 16, 1)
				SELECT 2001 AS ERROR_CODE
				GOTO ERROR_EXIT
			END
			--
			-- Cerco il livello di attendibilità per id del paziente
			--
			SELECT @LivelloAttendibilitaCorrente = LivelloAttendibilita
			FROM Pazienti 
			WHERE Id = @Id
		END

	SET @LivelloAttendibilita = dbo.LeggePazientiLivelloAttendibilita(@Utente)
	
	IF @LivelloAttendibilita < @LivelloAttendibilitaCorrente
		BEGIN
			RAISERROR('Errore sul controllo del Livello di Attendibilita!', 16, 1)
			RETURN 1001
		END

	---------------------------------------------------
	-- Controllo Codice Ficale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		RAISERROR('Errore durante PazientiWsBaseUpdate, il campo CodiceFiscale è vuoto!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRANSACTION

	---------------------------------------------------
	-- Eseguo fill dei codici ISTAT
	---------------------------------------------------
	SET @Msg = 'Paziente modificato con avvisi! '
	SET @MsgEvento = 'Dati paziente {Cognome:'+ISNULL(@Cognome,'')+
		'}, {Nome:'+ISNULL(@Nome,'')+
		'}, {DataNascita:'+ISNULL(CAST(@DataNascita AS VARCHAR(20)),'')+
		'}, {CodiceFiscale:'+ISNULL(@CodiceFiscale,'')+'}'

	IF NOT @ComuneNascitaCodice IS NULL
	BEGIN
		SET @ComuneNascitaCodice = RIGHT('000000' + @ComuneNascitaCodice,6)
		IF dbo.LookupIstatComuni(@ComuneNascitaCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'ComuneNascitaCodice sconosciuto! '
				
				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @ComuneNascitaCodice + ' - {Codice Sconosciuto}'
				EXEC dbo.IstatComuniInsert @ComuneNascitaCodice, @MsgIstat, '-1'
			END
	END

	IF NOT @ComuneResCodice IS NULL
	BEGIN
		SET @ComuneResCodice = RIGHT('000000' + @ComuneResCodice,6)
		IF dbo.LookupIstatComuni(@ComuneResCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'ComuneResCodice sconosciuto! '

				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @ComuneResCodice + ' - {Codice Sconosciuto}'
				EXEC dbo.IstatComuniInsert @ComuneResCodice, @MsgIstat, '-1'
			END
	END

	IF NOT @ComuneDomCodice IS NULL
	BEGIN
		SET @ComuneDomCodice = RIGHT('000000' + @ComuneDomCodice,6)
		IF dbo.LookupIstatComuni(@ComuneDomCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'ComuneDomCodice sconosciuto! '

				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @ComuneDomCodice + ' - {Codice Sconosciuto}'
				EXEC dbo.IstatComuniInsert @ComuneDomCodice, @MsgIstat, '-1'
			END
	END

	IF NOT @NazionalitaCodice IS NULL
	BEGIN
		SET @NazionalitaCodice = RIGHT('000' + @NazionalitaCodice,3)
		IF dbo.LookupIstatNazioni(@NazionalitaCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'NazionalitaCodice sconosciuto! '

				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @NazionalitaCodice + ' - {Codice Sconosciuto}'
				EXEC dbo.IstatNazioniInsert @NazionalitaCodice, @MsgIstat
			END
	END

	--
	-- MODIFICA ETTORE 2016-07-22:
	-- Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
	--
	SET @Tessera = dbo.ReplaceInvalidChar(@Tessera,'') 
	SET @Cognome = dbo.ReplaceInvalidChar(@Cognome, '') 
	SET @Nome = dbo.ReplaceInvalidChar(@Nome, '') 
	SET @CodiceFiscale = dbo.ReplaceInvalidChar(@CodiceFiscale, '') 
	SET @SubComuneRes = dbo.ReplaceInvalidChar(@SubComuneRes, '') 
	SET @IndirizzoRes = dbo.ReplaceInvalidChar(@IndirizzoRes, '') 
	SET @LocalitaRes = dbo.ReplaceInvalidChar(@LocalitaRes, '') 
	SET @SubComuneDom = dbo.ReplaceInvalidChar(@SubComuneDom, '') 
	SET @IndirizzoDom = dbo.ReplaceInvalidChar(@IndirizzoDom, '') 
	SET @LocalitaDom = dbo.ReplaceInvalidChar(@LocalitaDom, '') 
	SET @IndirizzoRecapito = dbo.ReplaceInvalidChar(@IndirizzoRecapito, '') 
	SET @LocalitaRecapito = dbo.ReplaceInvalidChar(@LocalitaRecapito, '') 
	SET @Telefono1 = dbo.ReplaceInvalidChar(@Telefono1, '') 
	SET @Telefono2 = dbo.ReplaceInvalidChar(@Telefono2, '') 
	SET @Telefono3 = dbo.ReplaceInvalidChar(@Telefono3, '')

	---------------------------------------------------
	-- Aggiorna record
	---------------------------------------------------

	UPDATE Pazienti
	SET DataModifica = GetDate()
		, DataSequenza = GetDate()

		, Tessera = @Tessera
		, Cognome = @Cognome
		, Nome = @Nome
		, DataNascita = @DataNascita
		, Sesso = @Sesso
		, ComuneNascitaCodice = ISNULL(@ComuneNascitaCodice, '000000')
		, NazionalitaCodice = @NazionalitaCodice
		, CodiceFiscale = @CodiceFiscale

		, ComuneResCodice = @ComuneResCodice
		, SubComuneRes = @SubComuneRes
		, IndirizzoRes = @IndirizzoRes
		, LocalitaRes = @LocalitaRes
		, CapRes = @CapRes

		, ComuneDomCodice = @ComuneDomCodice
		, SubComuneDom = @SubComuneDom
		, IndirizzoDom = @IndirizzoDom
		, LocalitaDom = @LocalitaDom
		, CapDom = @CapDom

		, IndirizzoRecapito = @IndirizzoRecapito
		, LocalitaRecapito = @LocalitaRecapito
		, Telefono1 = @Telefono1
		, Telefono2 = @Telefono2
		, Telefono3 = @Telefono3

		--
		-- Modify date: 2019-11-06 - Riattivazione anagrafiche cancellate logicamente [ASMN-4052]
		-- Aggiornamento del campo Disattivato:
		--		Se Disattivato = 0 (ATTIVO) o 2(FUSO) deve rimanere tale
		--		Se Disattivato = 1 (CANCELLATO) deve diventare 0 (ATTIVO)
		-- Affinchè funzioni ce ne deve essere uno solo di record con [Provenienza, IdProvenienza]=[@Provenienza, @IdProvenienza]
		--
		, Disattivato = CASE WHEN Disattivato = 1 THEN 0 
						ELSE Disattivato END 
		, DataDisattivazione = CASE WHEN Disattivato = 1 THEN NULL 
						ELSE DataDisattivazione END

	WHERE Id = @Id

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record d'evento
	---------------------------------------------------
	IF LEN(@Msg) > 35
		BEGIN
			SET @Msg = @Msg + @MsgEvento
			EXEC dbo.PazientiEventiAvvertimento @Utente, 0, 'PazientiWsBaseUpdate', @Msg
		END

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	EXEC PazientiNotificheAdd @Id, '2', @Utente
	
	COMMIT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	IF @@TRANCOUNT > 0
		  ROLLBACK TRANSACTION
	
	RETURN 1
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsBaseUpdate] TO [DataAccessWs]
    AS [dbo];

