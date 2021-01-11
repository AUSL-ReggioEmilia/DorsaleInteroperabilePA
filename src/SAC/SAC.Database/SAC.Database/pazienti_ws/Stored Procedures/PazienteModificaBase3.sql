

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-07 (derivata da versione precedente creata il 2019-11-25)
-- Description:	SP base pe l'aggiornamento di tutti i campi della tabella Pazienti 
--				Questa SP NON viene chiamata direttamenete dai metodi ma è chiamata da: 
--							pazienti_ws.PazienteModificaBase2
--							pazienti_ws.PazienteModificaByProvenienzaIdProvenienza2 
-- NOTE :
--		Eseguo sempre PADDING per i parametri @CodiceAslXXX e @ComuneAslXXXCodice
--		I flag Capofamiglia, Indigenza, MantenimentoPediatra vengono scritti sia nei campi strutturati che negli attributi
--		Riattivazione anagrafiche cancellate logicamente [ASMN-4052]
-- Modify date: 2020-05-07 - ETTORE: @ComuneAslResCodice e @ComuneAslAssCodice non vengono più valorizzati
--
-- TODO: fare un controllo basato su (@CodiceAslRes, @RegioneResCodice) e (@CodiceAslAss, @RegioneAssCodice) basato PROBABILMENTE sulla tabella dei DizionariIstat ( DA PENSARE)
--
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteModificaBase3]
(
	 @Utente AS varchar(64)
	-----------------------
	,@Id uniqueidentifier	    -- IDSAC del record paziente da aggiornare	
	-----------------------
	,@Provenienza varchar(16)   -- Provenienza e IdProvenienza per cercare il record oggetto della modifica
	,@IdProvenienza varchar(64) 
	-----------------------
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
			RAISERROR('Errore di controllo accessi durante PazienteModificaBase!', 16, 1)
			RETURN
		END

		---------------------------------------------------
		-- Controlla livello attendibilità; Aggiorna solo se pari o maggiore
		---------------------------------------------------	
		IF @Id IS NULL
			BEGIN
				---------------------------------------------------
				-- Controllo Provenienza e IdProvenienza
				---------------------------------------------------
				IF @Provenienza IS NULL
				BEGIN
					RAISERROR('Errore durante PazienteModificaBase, il campo Provenienza è vuoto!', 16, 1)
					RETURN
				END

				IF @IdProvenienza IS NULL
				BEGIN
					RAISERROR('Errore durante PazienteModificaBase, il campo IdProvenienza è vuoto!', 16, 1)
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
					RAISERROR('Errore durante PazienteModificaBase, paziente non trovato per Provenienza e IdProvenienza!', 16, 1)
					RETURN
				END
			END
		ELSE
		BEGIN	
			--
			-- Cerco il livello di attendibilità per Id del paziente
			--
			SELECT @LivelloAttendibilitaCorrente = LivelloAttendibilita
			FROM dbo.Pazienti 
			WHERE Id = @Id
			--
			-- Verifico se ho trovato il record, altrimenti genero errore
			--
			IF @LivelloAttendibilitaCorrente IS NULL
			BEGIN
				RAISERROR('Errore durante PazienteModificaBase, paziente non trovato per Id!', 16, 1)
				RETURN
			END
		END

		--
		-- Test sul Livello di Attendibilità dell'utente
		--
		SET @LivelloAttendibilita = dbo.LeggePazientiLivelloAttendibilita(@Utente)	
		IF @LivelloAttendibilita < @LivelloAttendibilitaCorrente
		BEGIN
			RAISERROR('Errore sul controllo del Livello di Attendibilità!', 16, 1)
			RETURN
		END

		---------------------------------------------------
		-- Controllo Codice Ficale
		---------------------------------------------------
		IF LEN(ISNULL(@CodiceFiscale, '')) = 0
		BEGIN
			RAISERROR('Errore durante PazienteModificaBase, il campo CodiceFiscale è vuoto!', 16, 1)
			RETURN
		END
		
		---------------------------------------------------
		-- Inizio transazione
		---------------------------------------------------
		BEGIN TRAN

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
				RAISERROR('Errore durante PazienteModificaBase, il valore del campo [@PosizioneAss] non è presente nella tabella PazientiPosizioneAss!', 16, 1)
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
		-- Aggiorna record
		---------------------------------------------------
		UPDATE dbo.Pazienti
		SET DataModifica = GetDate()
			,DataSequenza = GetDate()
			,Tessera = @Tessera 
			,Cognome = @Cognome
			,Nome = @Nome
			,DataNascita = @DataNascita
			,Sesso = @Sesso
			,ComuneNascitaCodice = ISNULL(@ComuneNascitaCodice, '000000')
			,NazionalitaCodice = @NazionalitaCodice 
			,CodiceFiscale = @CodiceFiscale 
			,MantenimentoPediatra = @MantenimentoPediatra
			,CapoFamiglia = @CapoFamiglia
			,Indigenza = @Indigenza 
			,CodiceTerminazione = @CodiceTerminazione 
			,DescrizioneTerminazione = @DescrizioneTerminazione 
			,ComuneResCodice = @ComuneResCodice 
			,SubComuneRes = @SubComuneRes 
			,IndirizzoRes = @IndirizzoRes 
			,LocalitaRes = @LocalitaRes 
			,CapRes = @CapRes 
			,DataDecorrenzaRes = @DataDecorrenzaRes 
			,CodiceAslRes = @CodiceAslRes 
			,ComuneDomCodice = @ComuneDomCodice 
			,SubComuneDom = @SubComuneDom 
			,IndirizzoDom = @IndirizzoDom 
			,LocalitaDom = @LocalitaDom 
			,CapDom = @CapDom 
			,PosizioneAss = @PosizioneAss 
			,CodiceAslAss = @CodiceAslAss 
			,DataInizioAss = @DataInizioAss 
			,DataScadenzaAss = @DataScadenzaAss 
			,DataTerminazioneAss = @DataTerminazioneAss 
			,DistrettoAmm = @DistrettoAmm 
			,DistrettoTer = @DistrettoTer 
			,Ambito = @Ambito 
			,CodiceMedicoDiBase = @CodiceMedicoDiBase 
			,CodiceFiscaleMedicoDiBase = @CodiceFiscaleMedicoDiBase 
			,CognomeNomeMedicoDiBase = @CognomeNomeMedicoDiBase 
			,DistrettoMedicoDiBase = @DistrettoMedicoDiBase 
			,DataSceltaMedicoDiBase = @DataSceltaMedicoDiBase 
			,ComuneRecapitoCodice = @ComuneRecapitoCodice 
			,IndirizzoRecapito = @IndirizzoRecapito 
			,LocalitaRecapito = @LocalitaRecapito 
			,Telefono1 = @Telefono1 
			,Telefono2 = @Telefono2 
			,Telefono3 = @Telefono3 
			,CodiceSTP = @CodiceSTP 
			,DataInizioSTP = @DataInizioSTP 
			,DataFineSTP = @DataFineSTP 
			,MotivoAnnulloSTP = @MotivoAnnulloSTP 
			,RegioneResCodice = @RegioneResCodice 
			,RegioneAssCodice = @RegioneAssCodice
			,Attributi = @Attributi

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
		WHERE ID = @Id


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