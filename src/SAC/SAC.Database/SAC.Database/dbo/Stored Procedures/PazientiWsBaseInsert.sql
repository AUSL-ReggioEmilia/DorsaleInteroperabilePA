


-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2016-07-22: ETTORE: Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
-- Modify date: 2016-12-28: ETTORE: Controllo se l'anagrafica esiste già cercandola per [Provenienza, IdProvenienza] nello stato ATTIVO o FUSO 
--									Aggiunto IF @@TRANCOUNT > 0 in caso di ROLLBACK
-- Description:	SP di inserimento paziente usata dai WS (aggiorna un set limitato di campi)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsBaseInsert]
	  @Utente AS varchar(64)

	, @Id uniqueidentifier
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

DECLARE @DataInserimento AS datetime
DECLARE @Provenienza varchar(16)

DECLARE @MsgEvento AS varchar(250)
DECLARE @MsgIstat AS varchar(64)
DECLARE @Msg AS varchar(500)

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiWsBaseInsert!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Controllo Codice Ficale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		RAISERROR('Errore durante PazientiWsBaseInsert, il campo CodiceFiscale è vuoto!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	--
	-- MODIFICA ETTORE 2016-12-28: Verifico se l'anagrafica esiste prima di eseguire l'inserimento
	--
	IF EXISTS (SELECT * FROM Pazienti WHERE Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza
				AND Disattivato IN (0,2) --se Cancellato non lo considero
			) 
	BEGIN 
		DECLARE @ErrMsg VARCHAR(512)
		SET @ErrMsg = 'Errore durante PazientiWsBaseInsert: l''anagrafica [Provenienza, IdProvenienza]=[' + @Provenienza + ', ' + @IdProvenienza + '] esiste già!'
		RAISERROR(@ErrMsg , 16, 1)
		SELECT 2101 AS ERROR_CODE
		GOTO ERROR_EXIT
	END 

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Eseguo fill dei codici ISTAT
	---------------------------------------------------
	SET @Msg = 'Paziente aggiunto con avvisi! '
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
	-- Inserisce record
	---------------------------------------------------

	IF @Id IS NULL SET @Id = NewId()
	SET @DataInserimento = GetDate()

	INSERT INTO Pazienti
		( 
		  Id
		, Provenienza
		, IdProvenienza
		, DataInserimento
		, DataModifica
		, DataSequenza
		, LivelloAttendibilita
		
		, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, ComuneNascitaCodice
		, NazionalitaCodice
		, CodiceFiscale

		, ComuneResCodice
		, SubComuneRes
		, IndirizzoRes
		, LocalitaRes
		, CapRes

		, ComuneDomCodice
		, SubComuneDom
		, IndirizzoDom
		, LocalitaDom
		, CapDom

		, IndirizzoRecapito
		, LocalitaRecapito
		, Telefono1
		, Telefono2
		, Telefono3)
	VALUES
		( 
		  @Id
		, @Provenienza
		, @IdProvenienza
		, @DataInserimento
		, @DataInserimento	--DataModifica
		, @DataInserimento	--DataSequenza
		, dbo.LeggePazientiLivelloAttendibilita(@Utente)
		
		, @Tessera
		, @Cognome
		, @Nome
		, @DataNascita
		, @Sesso
		, ISNULL(@ComuneNascitaCodice, '000000')
		, @NazionalitaCodice
		, @CodiceFiscale

		, @ComuneResCodice
		, @SubComuneRes
		, @IndirizzoRes
		, @LocalitaRes
		, @CapRes

		, @ComuneDomCodice
		, @SubComuneDom
		, @IndirizzoDom
		, @LocalitaDom
		, @CapDom

		, @IndirizzoRecapito
		, @LocalitaRecapito
		, @Telefono1
		, @Telefono2
		, @Telefono3)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record d'evento
	---------------------------------------------------
	IF LEN(@Msg) > 35
		BEGIN
			SET @Msg = @Msg + @MsgEvento
			EXEC dbo.PazientiEventiAvvertimento @Utente, 0, 'PazientiWsBaseInsert', @Msg
		END

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @Id, '2', @Utente
	
	COMMIT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	IF @@TRANCOUNT > 0 
		ROLLBACK
	RETURN 1

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsBaseInsert] TO [DataAccessWs]
    AS [dbo];

