





-- =============================================
-- Author:		ETTORE
-- Create date: 2019-11-25
-- Description:	SP Base per l'aggiornamento di un insieme ristretto di campi della tabella Pazienti
--				Aggiorna UN SOTTOINSIEME di campi della tabella Pazienti
--				Chiamata dalle: 
--					pazienti_ws.PazienteSemplificatoModificaBase
--					pazienti_ws.PazienteSemplificatoModificaByProvenienzaIdProvenienza
--				ETTORE: Riattivazione anagrafiche cancellate logicamente [ASMN-4052]
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteSemplificatoModificaBase]
(
	  @Utente AS varchar(64)
-----------------------------------------------
	, @Id uniqueidentifier				--valorizzato de chiamata pazienti_ws.PazienteSemplificatoModificaBase
-----------------------------------------------
	, @Provenienza varchar(16)			--valorizzati se chiamata pazienti_ws.PazienteSemplificatoModificaByProvenienzaIdProvenienza
	, @IdProvenienza varchar(64)
-----------------------------------------------	
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
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LivelloAttendibilita AS tinyint
	DECLARE @LivelloAttendibilitaCorrente AS tinyint
	DECLARE @MsgEvento AS varchar(250)
	DECLARE @MsgIstat AS varchar(64)
	DECLARE @Msg AS varchar(500)
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
		
BEGIN TRY	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggePazientiPermessiScrittura(@Utente) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Utente, 0, @ProcName, 'Utente non ha i permessi di scrittura!'
		RAISERROR('Errore di controllo accessi durante PazienteSemplificatoModificaBase!', 16, 1)
		RETURN
	END


	---------------------------------------------------
	-- Controlla livello attendibilità; Aggiorna solo se pari o maggiore
	---------------------------------------------------	
	IF @Id IS NULL
	BEGIN
		---------------------------------------------------
		-- Controllo @Provenienza e @IdProvenienza
		---------------------------------------------------
		IF @Provenienza IS NULL
		BEGIN
			RAISERROR('Errore durante PazienteSemplificatoModificaBase, il campo Provenienza è vuoto!', 16, 1)
			RETURN
		END
		IF @IdProvenienza IS NULL
		BEGIN
			RAISERROR('Errore durante PazienteSemplificatoModificaBase, il campo IdProvenienza è vuoto!', 16, 1)
			RETURN			
		END
		--
		-- Cerco il paziente e il livello di attendibilità per Provenienza, IdProvenienza
		--
		SELECT @Id = Id, @LivelloAttendibilitaCorrente = LivelloAttendibilita
		FROM dbo.Pazienti 
		WHERE Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza
		--
		-- Verifico se ho trovato il record, altrimenti genero errore
		--
		IF @Id IS NULL
		BEGIN
			RAISERROR('Errore durante PazienteSemplificatoModificaBase, paziente non trovato per Provenienza e IdProvenienza!', 16, 1)
			RETURN			
		END
	END
	ELSE BEGIN
		IF @Id IS NULL
		BEGIN
			RAISERROR('Errore durante PazienteSemplificatoModificaBase, il campo Id è vuoto!', 16, 1)
			RETURN			
		END
		--
		-- Cerco il livello di attendibilità per id del paziente
		--
		SELECT @LivelloAttendibilitaCorrente = LivelloAttendibilita
		FROM dbo.Pazienti 
		WHERE Id = @Id
	END

	SET @LivelloAttendibilita = dbo.LeggePazientiLivelloAttendibilita(@Utente)
	
	IF @LivelloAttendibilita < @LivelloAttendibilitaCorrente
	BEGIN
		RAISERROR('Errore sul controllo del Livello di Attendibilita!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Controllo Codice Ficale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		RAISERROR('Errore durante PazienteSemplificatoModificaBase, il campo CodiceFiscale è vuoto!', 16, 1)
		RETURN		
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

	UPDATE dbo.Pazienti	
	SET   DataModifica = GetDate()
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

	---------------------------------------------------
	-- Inserisce record d'evento
	---------------------------------------------------
	IF LEN(@Msg) > 35
	BEGIN
		SET @Msg = @Msg + @MsgEvento
		EXEC dbo.PazientiEventiAvvertimento @Utente, 0, @ProcName, @Msg
	END

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	EXEC dbo.PazientiNotificheAdd @Id, '2', @Utente
	
	COMMIT
	
	---------------------------------------------------
	-- Return
	---------------------------------------------------
	SELECT Id 
	FROM dbo.PazientiAttiviResult
	WHERE Id = @Id
	
		
END TRY
BEGIN CATCH

	---------------------------------------------------
	--     ROLLBACK TRANSAZIONE
	---------------------------------------------------
	IF @@TRANCOUNT > 0 ROLLBACK

	---------------------------------------------------
	--     GESTIONE ERRORI (LOG E PASSO FUORI)
	---------------------------------------------------
    DECLARE @Errmsg NVARCHAR(4000) = ERROR_MESSAGE()    
	EXEC dbo.PazientiEventiAvvertimento @Utente, 0, @ProcName, @Errmsg
	-- PASSO FUORI L'ECCEZIONE
	;THROW;

END CATCH

END