
-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	Inserimento record paziente
-- MODIFICA ETTORE 2014-07-08: Se @ComuneNascitaCodice è NULL viene salvato '000000'
-- MODIFICA ETTORE 2016-05-26: Eliminata la chiamata alla SP EXEC PazientiNotificheAdd @IdPaziente, '0', @Utente
--			 				perchè ora viene fatta all'interno della data access
-- MODIFICA ETTORE 2016-07: Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
-- MODIFICA ETTORE 2017-05-23: Eseguo sempre PADDING per i parametri @CodiceAslXXX e @ComuneAslXXXCodice
--							Prima poteva capitare di inserire '0' invece di '000'
-- Modify date: 2018-08-01 - ETTORE: Nuovo campo Attributi XML
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgBaseInsert]
(
	  @Utente AS varchar(64)
	, @IdProvenienza AS varchar(64)
	, @DataSequenza AS datetime
	
	, @Tessera varchar(16)
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @Sesso varchar(1)
	, @ComuneNascitaCodice varchar(6)
	, @NazionalitaCodice varchar(3)
	, @CodiceFiscale varchar(16)
	
	, @DatiAnamnestici varchar(8000)
	, @MantenimentoPediatra bit
	, @CapoFamiglia bit
	, @Indigenza bit
	, @CodiceTerminazione varchar(8)
	, @DescrizioneTerminazione varchar(64)
	
	, @ComuneResCodice varchar(6)
	, @SubComuneRes varchar(64)
	, @IndirizzoRes varchar(256)
	, @LocalitaRes varchar(128)
	, @CapRes varchar(8)
	, @DataDecorrenzaRes datetime

	, @ComuneAslResCodice varchar(6)
	, @CodiceAslRes varchar(3)
	, @RegioneResCodice varchar(3)
	
	, @ComuneDomCodice varchar(6)
	, @SubComuneDom varchar(64)
	, @IndirizzoDom varchar(256)
	, @LocalitaDom varchar(128)
	, @CapDom varchar(8)
	
	, @PosizioneAss tinyint
	, @RegioneAssCodice varchar(3)

	, @ComuneAslAssCodice varchar(6)
	, @CodiceAslAss varchar(3)
	, @DataInizioAss datetime
	, @DataScadenzaAss datetime
	, @DataTerminazioneAss datetime
	, @DistrettoAmm varchar(8)
	, @DistrettoTer varchar(16)
	, @Ambito varchar(16)
	
	, @CodiceMedicoDiBase int
	, @CodiceFiscaleMedicoDiBase varchar(16)
	, @CognomeNomeMedicoDiBase varchar(128)
	, @DistrettoMedicoDiBase varchar(8)
	, @DataSceltaMedicoDiBase datetime
	
	, @ComuneRecapitoCodice varchar(6)
	, @IndirizzoRecapito varchar(256)
	, @LocalitaRecapito varchar(128)
	, @Telefono1 varchar(20)
	, @Telefono2 varchar(20)
	, @Telefono3 varchar(20)
	, @CodiceSTP varchar(32)
	
	, @DataInizioSTP datetime
	, @DataFineSTP datetime
	, @MotivoAnnulloSTP varchar(8)
	-- Modify date: 2018-08-01 - ETTORE: Nuovo campo Attributi XML
	, @Attributi AS XML = NULL
)
AS
BEGIN
	DECLARE @IdPaziente as uniqueidentifier
	DECLARE @Provenienza AS varchar(16)
	DECLARE @DataInserimento AS datetime
	DECLARE @RowCount AS integer
	DECLARE @MsgEvento AS varchar(250)
	DECLARE @MsgIstat AS varchar(64)
	DECLARE @Msg AS varchar(500)

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiScrittura(@Utente) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiInsert', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante [PazientiMsgBaseInsert]!', 16, 1)
		SELECT 1002 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante [PazientiMsgBaseInsert]!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Controllo Codice Ficale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		RAISERROR('Errore durante PazientiMsgBaseInsert, il campo CodiceFiscale è vuoto!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Eseguo fill dei codici ISTAT
	---------------------------------------------------
	SET @Msg = 'Paziente inserito con avvisi! '
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
			EXEC dbo.IstatComuniInsert @ComuneNascitaCodice, @MsgIstat, '-1', @Provenienza, @IdProvenienza
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
			EXEC dbo.IstatComuniInsert @ComuneResCodice, @MsgIstat, '-1', @Provenienza, @IdProvenienza
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
			EXEC dbo.IstatComuniInsert @ComuneDomCodice, @MsgIstat, '-1', @Provenienza, @IdProvenienza
		END
	END

	IF NOT @ComuneRecapitoCodice IS NULL
	BEGIN
		SET @ComuneRecapitoCodice = RIGHT('000000' + @ComuneRecapitoCodice,6)
		IF dbo.LookupIstatComuni(@ComuneRecapitoCodice) IS NULL
		BEGIN
			SET @Msg = @Msg + 'ComuneRecapitoCodice sconosciuto! '

			---------------------------------------------------
			-- Aggiungo il codice istat
			---------------------------------------------------
			SET @MsgIstat = @ComuneRecapitoCodice + ' - {Codice Sconosciuto}'
			EXEC dbo.IstatComuniInsert @ComuneRecapitoCodice, @MsgIstat, '-1', @Provenienza, @IdProvenienza
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

	IF NOT @RegioneAssCodice IS NULL
	BEGIN
		SET @RegioneAssCodice = RIGHT('000' + @RegioneAssCodice,3)
		IF dbo.LookupIstatRegioni(@RegioneAssCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'RegioneAssCodice sconosciuto! '

				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @RegioneAssCodice + ' - {Codice Sconosciuto}'
				EXEC dbo.IstatRegioniInsert @RegioneAssCodice, @MsgIstat, ''
			END
	END

	IF NOT @RegioneResCodice IS NULL
	BEGIN
		SET @RegioneResCodice = RIGHT('000' + @RegioneResCodice,3)
		IF dbo.LookupIstatRegioni(@RegioneResCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'RegioneResCodice sconosciuto! '

				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @RegioneResCodice + ' - {Codice Sconosciuto}'
				EXEC dbo.IstatRegioniInsert @RegioneResCodice, @MsgIstat, ''
			END
	END

	--
	-- MODIFICA ETTORE 2017-05-23: mi assicuro che i parametri sia sempre PADDED correttamente
	--
	SET @CodiceAslAss  = ISNULL(RIGHT('000' + @CodiceAslAss,3), '000')
	SET @ComuneAslAssCodice = ISNULL(RIGHT('000000' + @ComuneAslAssCodice,6), '000000')

	IF (NOT @CodiceAslAss IS NULL) AND (NOT @ComuneAslAssCodice IS NULL)
	BEGIN
		--SET @CodiceAslAss  = RIGHT('000' + @CodiceAslAss,3)
		--SET @ComuneAslAssCodice = RIGHT('000000' + @ComuneAslAssCodice,6)
		IF dbo.LookupIstatAsl(@CodiceAslAss,@ComuneAslAssCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'CodiceAslAss e/o ComuneAslAssCodice sconosciuto! '

				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @CodiceAslAss + '|' + @ComuneAslAssCodice + '- {Codice Sconosciuto}'
				EXEC dbo.IstatAslInsert @CodiceAslAss, @ComuneAslAssCodice, @MsgIstat, ''
			END
	END

	--
	-- Valorizzo @ComuneAslAssCodice perchè splittato
	-- 
	IF (@CodiceAslAss IS NOT NULL) AND (@ComuneAslAssCodice IS NULL) 
		AND (@ComuneDomCodice IS NOT NULL)
	BEGIN
		SET @ComuneAslAssCodice = @ComuneDomCodice
	END
	

	--
	-- MODIFICA ETTORE 2017-05-23: mi assicuro che i parametri sia sempre PADDED correttamente
	--
	SET @CodiceAslRes  = ISNULL(RIGHT('000' + @CodiceAslRes,3), '000')
	SET @ComuneAslResCodice = ISNULL(RIGHT('000000' + @ComuneAslResCodice,6), '000000')

	IF (NOT @CodiceAslRes IS NULL) AND (NOT @ComuneAslResCodice IS NULL)
	BEGIN
		--SET @CodiceAslRes  = RIGHT('000' + @CodiceAslRes,3)
		--SET @ComuneAslResCodice = RIGHT('000000' + @ComuneAslResCodice,6)
		IF dbo.LookupIstatAsl(@CodiceAslRes,@ComuneAslResCodice) IS NULL
			BEGIN
				SET @Msg = @Msg + 'CodiceAslRes e/o ComuneAslResCodice sconosciuto! '

				---------------------------------------------------
				-- Aggiungo il codice istat
				---------------------------------------------------
				SET @MsgIstat = @CodiceAslRes + '|' + @ComuneAslResCodice + '- {Codice Sconosciuto}'
				EXEC dbo.IstatAslInsert @CodiceAslRes, @ComuneAslResCodice, @MsgIstat, ''
			END
	END

	--
	-- Valorizzo @ComuneAslResCodice perchè splittato
	-- 
	IF (@CodiceAslRes IS NOT NULL) AND (@ComuneAslResCodice IS NULL) 
		AND (@ComuneResCodice IS NOT NULL)
	BEGIN
		SET @ComuneAslResCodice = @ComuneResCodice
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
	SET @CognomeNomeMedicoDiBase = dbo.ReplaceInvalidChar(@CognomeNomeMedicoDiBase, '') 
	SET @IndirizzoRecapito = dbo.ReplaceInvalidChar(@IndirizzoRecapito, '') 
	SET @LocalitaRecapito = dbo.ReplaceInvalidChar(@LocalitaRecapito, '') 
	SET @Telefono1 = dbo.ReplaceInvalidChar(@Telefono1, '') 
	SET @Telefono2 = dbo.ReplaceInvalidChar(@Telefono2, '') 
	SET @Telefono3 = dbo.ReplaceInvalidChar(@Telefono3, '') 
		
	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	SET @IdPaziente = newid()
	SET @DataInserimento = GetDate()
	
	SET NOCOUNT OFF;

	INSERT INTO Pazienti
		( Id
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

		, DatiAnamnestici
		, MantenimentoPediatra
		, CapoFamiglia
		, Indigenza
		, CodiceTerminazione
		, DescrizioneTerminazione

		, ComuneResCodice
		, SubComuneRes
		, IndirizzoRes
		, LocalitaRes
		, CapRes
		, DataDecorrenzaRes
		, ComuneAslResCodice
		, CodiceAslRes
		, RegioneResCodice

		, ComuneDomCodice
		, SubComuneDom
		, IndirizzoDom
		, LocalitaDom
		, CapDom

		, PosizioneAss
		, RegioneAssCodice
		, ComuneAslAssCodice
		, CodiceAslAss
		, DataInizioAss
		, DataScadenzaAss
		, DataTerminazioneAss
		, DistrettoAmm
		, DistrettoTer
		, Ambito

		, CodiceMedicoDiBase
		, CodiceFiscaleMedicoDiBase
		, CognomeNomeMedicoDiBase
		, DistrettoMedicoDiBase
		, DataSceltaMedicoDiBase

		, ComuneRecapitoCodice
		, IndirizzoRecapito
		, LocalitaRecapito
		, Telefono1
		, Telefono2
		, Telefono3
		, CodiceSTP

		, DataInizioSTP
		, DataFineSTP
		, MotivoAnnulloSTP
		, Attributi 
		)
	VALUES
		( @IdPaziente
		, @Provenienza
		, @IdProvenienza
		, @DataInserimento
		, @DataInserimento
		, @DataSequenza
		, dbo.LeggePazientiLivelloAttendibilita(@Utente)
		
		, @Tessera
		, @Cognome
		, @Nome
		, @DataNascita
		, @Sesso
		, ISNULL(@ComuneNascitaCodice, '000000')
		, @NazionalitaCodice
		, @CodiceFiscale

		, CONVERT(varbinary(max), NULLIF(@DatiAnamnestici, ''))
		, @MantenimentoPediatra
		, @CapoFamiglia
		, @Indigenza
		, @CodiceTerminazione
		, @DescrizioneTerminazione

		, @ComuneResCodice
		, @SubComuneRes
		, @IndirizzoRes
		, @LocalitaRes
		, @CapRes
		, @DataDecorrenzaRes
		, @ComuneAslResCodice
		, @CodiceAslRes
		, @RegioneResCodice

		, @ComuneDomCodice
		, @SubComuneDom
		, @IndirizzoDom
		, @LocalitaDom
		, @CapDom

		, @PosizioneAss
		, @RegioneAssCodice
		, @ComuneAslAssCodice
		, @CodiceAslAss
		, @DataInizioAss
		, @DataScadenzaAss
		, @DataTerminazioneAss
		, @DistrettoAmm
		, @DistrettoTer
		, @Ambito

		, @CodiceMedicoDiBase
		, @CodiceFiscaleMedicoDiBase
		, @CognomeNomeMedicoDiBase
		, @DistrettoMedicoDiBase
		, @DataSceltaMedicoDiBase

		, @ComuneRecapitoCodice
		, @IndirizzoRecapito
		, @LocalitaRecapito
		, @Telefono1
		, @Telefono2
		, @Telefono3
		, @CodiceSTP

		, @DataInizioSTP
		, @DataFineSTP
		, @MotivoAnnulloSTP
		, @Attributi 
		)

	SET @RowCount = @@ROWCOUNT
	IF @RowCount = 0
		BEGIN
			RAISERROR('Errore di nessun record inserito durante PazientiMsgBaseInsert!', 16, 1)
			SELECT 2002 AS ERROR_CODE
			GOTO ERROR_EXIT
		END

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inserisce record d'evento
	---------------------------------------------------
	IF LEN(@Msg) > 35
		BEGIN
			SET @Msg = @Msg + @MsgEvento
			EXEC dbo.PazientiEventiAvvertimento @Utente, 0, 'PazientiMsgBaseInsert', @Msg
		END


	---------------------------------------------------
	-- Tentativo di aggangio consensi anonimi
	---------------------------------------------------
	BEGIN TRY
		EXEC dbo.ConsensiBatchAggancioPazienteUpdate @Utente, @IdPaziente, @Provenienza, @IdProvenienza, @CodiceFiscale
	END TRY
	BEGIN CATCH
		EXEC dbo.PazientiEventiAvvertimento @Utente, 0, 'PazientiMsgBaseInsert', 'Errore durante il tentativo di aggancio consensi anonimi.'
	END CATCH

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	SELECT @RowCount AS ROW_COUNT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	RETURN 1

END;




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgBaseInsert] TO [DataAccessDll]
    AS [dbo];

