


-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2016-07-22: ETTORE: Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
-- Modify date: 2016-12-28: ETTORE: Controllo se l'anagrafica esiste già cercandola per [Provenienza, IdProvenienza] nello stato ATTIVO o FUSO 
--									Aggiunto IF @@TRANCOUNT > 0 in caso di ROLLBACK
-- MODIFICA ETTORE 2017-05-23: Eseguo sempre PADDING per i parametri @CodiceAslXXX e @ComuneAslXXXCodice
-- MODIFICA ETTORE 2018-09-21: Aggiornamento del campo Attributi
-- Description:	SP di inserimento paziente usata dai WS (aggiorna tutti i campi della tabella pazienti)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsBaseInsert3]
(
	@Utente AS varchar(64)
	,@Id uniqueidentifier
	,@IdProvenienza varchar(64) 
	,@Tessera varchar(16) 
	,@Cognome varchar(64) 
	,@Nome varchar(64) 
	,@DataNascita datetime 
	,@Sesso varchar(1) 
	,@ComuneNascitaCodice varchar(6) 
	,@NazionalitaCodice varchar(3) 
	,@CodiceFiscale varchar(16) 
	,@MantenimentoPediatra bit 
	,@CapoFamiglia bit 
	,@Indigenza bit 
	,@CodiceTerminazione varchar(8) 
	,@DescrizioneTerminazione varchar(64) 
	,@ComuneResCodice varchar(6) 
	,@SubComuneRes varchar(64) 
	,@IndirizzoRes varchar(256) 
	,@LocalitaRes varchar(128) 
	,@CapRes varchar(8) 
	,@DataDecorrenzaRes datetime 
	,@ComuneAslResCodice varchar(6) 
	,@CodiceAslRes varchar(3) 
	,@ComuneDomCodice varchar(6) 
	,@SubComuneDom varchar(64) 
	,@IndirizzoDom varchar(256) 
	,@LocalitaDom varchar(128) 
	,@CapDom varchar(8) 
	,@PosizioneAss tinyint 
	,@ComuneAslAssCodice varchar(6) 
	,@CodiceAslAss varchar(3) 
	,@DataInizioAss datetime 
	,@DataScadenzaAss datetime 
	,@DataTerminazioneAss datetime 
	,@DistrettoAmm varchar(8) 
	,@DistrettoTer varchar(16) 
	,@Ambito varchar(16) 
	,@CodiceMedicoDiBase int 
	,@CodiceFiscaleMedicoDiBase varchar(16) 
	,@CognomeNomeMedicoDiBase varchar(128) 
	,@DistrettoMedicoDiBase varchar(8) 
	,@DataSceltaMedicoDiBase datetime 
	,@ComuneRecapitoCodice varchar(6) 
	,@IndirizzoRecapito varchar(256) 
	,@LocalitaRecapito varchar(128) 
	,@Telefono1 varchar(20) 
	,@Telefono2 varchar(20) 
	,@Telefono3 varchar(20) 
	,@CodiceSTP varchar(32) 
	,@DataInizioSTP datetime 
	,@DataFineSTP datetime 
	,@MotivoAnnulloSTP varchar(8) 
	,@RegioneResCodice varchar(3) 
	,@RegioneAssCodice varchar(3)	
)
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
		RAISERROR('Errore di Provenienza non trovata durante PazientiWsBaseInsert3!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Controllo Codice Ficale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		RAISERROR('Errore durante PazientiWsBaseInsert3, il campo CodiceFiscale è vuoto!', 16, 1)
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
		SET @ErrMsg = 'Errore durante PazientiWsBaseInsert3: l''anagrafica [Provenienza, IdProvenienza]=[' + @Provenienza + ', ' + @IdProvenienza + '] esiste già!'
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
	-- Controllo ulteriori campi ISTAT
	--
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
				EXEC dbo.IstatComuniInsert @ComuneRecapitoCodice, @MsgIstat, '-1'
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
	--
	-- Verifico integrità referenziale 
	--
	--IF @ComuneAslResCodice = '' SET @ComuneAslResCodice = NULL
	--IF @CodiceAslRes = '' SET @CodiceAslRes = NULL
	--
	-- MODIFICA ETTORE 2017-05-23: mi assicuro che i parametri sia sempre PADDED correttamente
	--
	SET @CodiceAslRes  = ISNULL(RIGHT('000' + @CodiceAslRes,3), '000')
	SET @ComuneAslResCodice = ISNULL(RIGHT('000000' + @ComuneAslResCodice,6), '000000')
	IF (NOT @CodiceAslRes IS NULL) AND (NOT @ComuneAslResCodice IS NULL)
	BEGIN 
		IF dbo.LookupIstatAsl(@CodiceAslRes, @ComuneAslResCodice) IS NULL
		BEGIN 
			RAISERROR('Errore durante PazientiWsBaseInsert3, la coppia [@CodiceAslRes, @ComuneAslResCodice] non è presente nella tabella IstatAsl!', 16, 1)
			SELECT 2001 AS ERROR_CODE
			GOTO ERROR_EXIT
		END
	END 
	--IF @ComuneAslAssCodice = '' SET @ComuneAslAssCodice = NULL
	--IF @CodiceAslAss = '' SET @CodiceAslAss = NULL 
	--
	-- MODIFICA ETTORE 2017-05-23: mi assicuro che i parametri sia sempre PADDED correttamente
	--
	SET @CodiceAslAss  = ISNULL(RIGHT('000' + @CodiceAslAss,3), '000')
	SET @ComuneAslAssCodice = ISNULL(RIGHT('000000' + @ComuneAslAssCodice,6), '000000')
	IF (NOT @CodiceAslAss IS NULL) AND (NOT @ComuneAslAssCodice IS NULL)
	BEGIN 
		IF dbo.LookupIstatAsl(@CodiceAslAss, @ComuneAslAssCodice) IS NULL
		BEGIN 
			RAISERROR('Errore durante PazientiWsBaseInsert3, la coppia [@CodiceAslAss, @ComuneAslAssCodice] non è presente nella tabella IstatAsl!', 16, 1)
			SELECT 2001 AS ERROR_CODE
			GOTO ERROR_EXIT
		END
	END 
	
	IF NOT @PosizioneAss IS NULL 
	BEGIN 
		IF dbo.LookupPazientiPosizioneAss(@PosizioneAss) IS NULL
		BEGIN
			RAISERROR('Errore durante PazientiWsBaseInsert3, il valore del campo [@PosizioneAss] non è presente nella tabella PazientiPosizioneAss!', 16, 1)
			SELECT 2001 AS ERROR_CODE
			GOTO ERROR_EXIT
		END 
	END 
	--
	-- Metto a NULL le stringhe vuote
	--	
	IF @Tessera = '' SET @Tessera = NULL	
	IF @Sesso = '' SET @Sesso = NULL
	IF @CodiceTerminazione = '' SET @CodiceTerminazione = NULL
	IF @DescrizioneTerminazione = '' SET @DescrizioneTerminazione = NULL
	IF @SubComuneRes = '' SET @SubComuneRes = NULL
	IF @IndirizzoRes = '' SET @IndirizzoRes = NULL
	IF @LocalitaRes = '' SET @LocalitaRes = NULL
	IF @CapRes = '' SET @CapRes = NULL
	IF @SubComuneDom = '' SET @SubComuneDom = NULL
	IF @IndirizzoDom = '' SET @IndirizzoDom = NULL
	IF @LocalitaDom = '' SET @LocalitaDom = NULL
	IF @CapDom = '' SET @CapDom = NULL
	IF @DistrettoAmm = '' SET @DistrettoAmm = NULL
	IF @DistrettoTer = '' SET @DistrettoTer = NULL
	IF @Ambito = '' SET @Ambito = NULL
	IF @CodiceFiscaleMedicoDiBase = '' SET @CodiceFiscaleMedicoDiBase = NULL
	IF @CognomeNomeMedicoDiBase = '' SET @CognomeNomeMedicoDiBase = NULL
	IF @DistrettoMedicoDiBase = '' SET @DistrettoMedicoDiBase = NULL
	IF @IndirizzoRecapito = '' SET @IndirizzoRecapito = NULL
	IF @LocalitaRecapito = '' SET @LocalitaRecapito = NULL
	IF @Telefono1 = '' SET @Telefono1 = NULL
	IF @Telefono2 = '' SET @Telefono2 = NULL
	IF @Telefono3 = '' SET @Telefono3 = NULL
	IF @CodiceSTP = '' SET @CodiceSTP = NULL
	IF @MotivoAnnulloSTP = '' SET @MotivoAnnulloSTP = NULL
	IF @RegioneResCodice = '' SET @RegioneResCodice = NULL
	IF @RegioneAssCodice = '' SET @RegioneAssCodice = NULL

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


	--
	-- Aggiorno il campo Attributi in base ai valori dei campi MantenimentoPediatra, Capofamiglia e Indigenza
	-- Da Messaggistica BT solo questi campi entrano negli attributi
	-- Da WS devo mantenere sincronizzato il campo Attributi
	--
	DECLARE @Capofamiglia_Value VARCHAR(10) = CASE WHEN @Capofamiglia = 1 THEN 'true' WHEN @Capofamiglia = 0 THEN 'false' ELSE NULL END
	DECLARE @MantenimentoPediatra_Value VARCHAR(10) = CASE WHEN @MantenimentoPediatra = 1 THEN 'true' WHEN @MantenimentoPediatra = 0 THEN 'false' ELSE NULL END
	DECLARE @Indigenza_Value VARCHAR(10) = CASE WHEN @Indigenza = 1 THEN 'true' WHEN @Indigenza = 0 THEN 'false' ELSE NULL END

	DECLARE @Attributi AS XML = '<Attributi></Attributi>' --INSERIMENTO: inizio con il nodo padre vuoto
	SET @Attributi = dbo.AttributiXmlAddAttributo(@Attributi , 'Capofamiglia', @Capofamiglia_Value)
	SET @Attributi = dbo.AttributiXmlAddAttributo(@Attributi , 'Indigenza', @Indigenza_Value)
	SET @Attributi = dbo.AttributiXmlAddAttributo(@Attributi , 'MantenimentoPediatra', @MantenimentoPediatra_Value)
	--Verifico che ci sia almeno un Attributo
	DECLARE @Count INT = @Attributi.value('count(/Attributi/Attributo)', 'int')
	IF @Count = 0
		SET @Attributi = NULL

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	IF @Id IS NULL SET @Id = NewId()
	SET @DataInserimento = GetDate()

	INSERT INTO Pazienti
		( 
		  Id
		, Provenienza
		,IdProvenienza
		
		, DataInserimento
		, DataModifica
		, DataSequenza
		, LivelloAttendibilita		
		
		,Tessera
		,Cognome
		,Nome
		,DataNascita
		,Sesso
		,ComuneNascitaCodice
		,NazionalitaCodice
		,CodiceFiscale
		,MantenimentoPediatra
		,CapoFamiglia
		,Indigenza
		,CodiceTerminazione
		,DescrizioneTerminazione
		,ComuneResCodice
		,SubComuneRes
		,IndirizzoRes
		,LocalitaRes
		,CapRes
		,DataDecorrenzaRes
		,ComuneAslResCodice
		,CodiceAslRes
		,ComuneDomCodice
		,SubComuneDom
		,IndirizzoDom
		,LocalitaDom
		,CapDom
		,PosizioneAss
		,ComuneAslAssCodice
		,CodiceAslAss
		,DataInizioAss
		,DataScadenzaAss
		,DataTerminazioneAss
		,DistrettoAmm
		,DistrettoTer
		,Ambito
		,CodiceMedicoDiBase
		,CodiceFiscaleMedicoDiBase
		,CognomeNomeMedicoDiBase
		,DistrettoMedicoDiBase
		,DataSceltaMedicoDiBase
		,ComuneRecapitoCodice
		,IndirizzoRecapito
		,LocalitaRecapito
		,Telefono1
		,Telefono2
		,Telefono3
		,CodiceSTP
		,DataInizioSTP
		,DataFineSTP
		,MotivoAnnulloSTP
		,RegioneResCodice
		,RegioneAssCodice
		,Attributi 
		)  	
	VALUES
		( 
		  @Id
		, @Provenienza
		,@IdProvenienza
		
		, GETDATE() --DataInserimento
		, GETDATE() --DataModifica
		, GETDATE() --DataSequenza
		, dbo.LeggePazientiLivelloAttendibilita(@Utente)
		
		,@Tessera
		,@Cognome
		,@Nome
		,@DataNascita
		,@Sesso
		,ISNULL(@ComuneNascitaCodice, '000000')
		,@NazionalitaCodice
		,@CodiceFiscale
		,@MantenimentoPediatra
		,@CapoFamiglia
		,@Indigenza
		,@CodiceTerminazione
		,@DescrizioneTerminazione
		,@ComuneResCodice
		,@SubComuneRes
		,@IndirizzoRes
		,@LocalitaRes
		,@CapRes
		,@DataDecorrenzaRes
		,@ComuneAslResCodice
		,@CodiceAslRes
		,@ComuneDomCodice
		,@SubComuneDom
		,@IndirizzoDom
		,@LocalitaDom
		,@CapDom
		,@PosizioneAss
		,@ComuneAslAssCodice
		,@CodiceAslAss
		,@DataInizioAss
		,@DataScadenzaAss
		,@DataTerminazioneAss
		,@DistrettoAmm
		,@DistrettoTer
		,@Ambito
		,@CodiceMedicoDiBase
		,@CodiceFiscaleMedicoDiBase
		,@CognomeNomeMedicoDiBase
		,@DistrettoMedicoDiBase
		,@DataSceltaMedicoDiBase
		,@ComuneRecapitoCodice
		,@IndirizzoRecapito
		,@LocalitaRecapito
		,@Telefono1
		,@Telefono2
		,@Telefono3
		,@CodiceSTP
		,@DataInizioSTP
		,@DataFineSTP
		,@MotivoAnnulloSTP
		,@RegioneResCodice
		,@RegioneAssCodice
		,@Attributi 
	)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record d'evento
	---------------------------------------------------
	IF LEN(@Msg) > 35
		BEGIN
			SET @Msg = @Msg + @MsgEvento
			EXEC dbo.PazientiEventiAvvertimento @Utente, 0, 'PazientiWsBaseInsert3', @Msg
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
    ON OBJECT::[dbo].[PazientiWsBaseInsert3] TO [DataAccessWs]
    AS [dbo];

