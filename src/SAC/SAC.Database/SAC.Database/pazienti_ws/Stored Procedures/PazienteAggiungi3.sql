

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-07 (derivata da versione precedente creata il 2019-11-12)
-- Description:	Inserimento di un nuovo paziente con gestione degli Attributi
-- Note:
--		Eseguo sempre PADDING per i parametri @CodiceAslXXX e @ComuneAslXXXCodice
--		I flag Capofamiglia, Indigenza, MantenimentoPediatra vengono scritti sia nei campi strutturati che negli attributi
--
-- Modify date: 2020-05-07 - ETTORE: @ComuneAslResCodice e @ComuneAslAssCodice non vengono più valorizzati
--
-- TODO: fare un controllo basato su (@CodiceAslRes, @RegioneResCodice) e (@CodiceAslAss, @RegioneAssCodice) basato PROBABILMENTE sulla tabella dei DizionariIstat ( DA PENSARE)
--
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteAggiungi3]
(
	 @Utente AS varchar(64)
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
	,@CodiceAslRes varchar(3) 
	,@ComuneDomCodice varchar(6) 
	,@SubComuneDom varchar(64) 
	,@IndirizzoDom varchar(256) 
	,@LocalitaDom varchar(128) 
	,@CapDom varchar(8) 
	,@PosizioneAss tinyint 
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
	,@Attributi XML = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @DataInserimento AS DATETIME = GETDATE()
	DECLARE @Provenienza varchar(16)
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
			RAISERROR('Errore di controllo accessi!', 16, 1)
			RETURN
		END

		---------------------------------------------------
		-- Calcolo provenienza da utente
		---------------------------------------------------
		SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
		IF @Provenienza IS NULL
		BEGIN
			RAISERROR('Errore, Provenienza non trovata!', 16, 1)
			RETURN
		END

		---------------------------------------------------
		-- Controllo Codice Ficale
		---------------------------------------------------
		IF LEN(ISNULL(@CodiceFiscale, '')) = 0
		BEGIN
			RAISERROR('Errore, il campo CodiceFiscale è vuoto!', 16, 1)
			RETURN
		END


		---------------------------------------------------
		-- Controllo Presenza dello stesso paziente in stato ATTIVO O FUSO 
		---------------------------------------------------
		IF EXISTS (SELECT * FROM dbo.Pazienti
				  WHERE Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza
				  AND Disattivato IN (0,2)  )
		BEGIN
			DECLARE @PazMsg VARCHAR(512)= 'Errore: l''anagrafica [Provenienza, IdProvenienza]=[' + @Provenienza + ', ' + @IdProvenienza + '] esiste già!'
			RAISERROR(@PazMsg, 16, 1)
			RETURN
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
		-- MODIFICA ETTORE 2017-05-23: mi assicuro che i parametri sia sempre PADDED correttamente
		--
		SET @CodiceAslRes  = ISNULL(RIGHT('000' + @CodiceAslRes,3), '000')
		SET @CodiceAslAss  = ISNULL(RIGHT('000' + @CodiceAslAss,3), '000')
	
		IF NOT @PosizioneAss IS NULL 
		BEGIN 
			IF dbo.LookupPazientiPosizioneAss(@PosizioneAss) IS NULL
			BEGIN
				RAISERROR('Errore, il valore del campo [@PosizioneAss] non è presente nella tabella PazientiPosizioneAss!', 16, 1)
				RETURN
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
		DECLARE @Id uniqueidentifier
		SET @Id = NEWID()

		INSERT INTO Pazienti
			( 
			 Id
			,Provenienza
			,IdProvenienza		
			,DataInserimento
			,DataModifica
			,DataSequenza
			,LivelloAttendibilita		
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
			,CodiceAslRes
			,ComuneDomCodice
			,SubComuneDom
			,IndirizzoDom
			,LocalitaDom
			,CapDom
			,PosizioneAss
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
			,@Provenienza
			,@IdProvenienza		
			,GETDATE() --DataInserimento
			,GETDATE() --DataModifica
			,GETDATE() --DataSequenza
			,dbo.LeggePazientiLivelloAttendibilita(@Utente)		
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
			,@CodiceAslRes
			,@ComuneDomCodice
			,@SubComuneDom
			,@IndirizzoDom
			,@LocalitaDom
			,@CapDom
			,@PosizioneAss
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
		EXEC PazientiNotificheAdd @Id, '2', @Utente
	
		COMMIT

		---------------------------------------------------
		-- Restituisco l'ID al chiamante
		---------------------------------------------------
		SELECT @Id AS Id


	END TRY
	BEGIN CATCH

		---------------------------------------------------
		--     ROLLBACK TRANSAZIONE
		---------------------------------------------------
		IF @@TRANCOUNT > 0 ROLLBACK

		---------------------------------------------------
		--     GESTIONE ERRORI (LOG E PASSO FUORI)
		---------------------------------------------------
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE()    
		EXEC dbo.PazientiEventiAvvertimento @Utente, 0, @ProcName, @ErrMsg
		-- PASSO FUORI L'ECCEZIONE
		;THROW;

	END CATCH

END