




-- =============================================
-- Author:		Ettore
-- Create date: 2020-10-20
-- Description:	Aggiorna una anagrafica ARA
-- =============================================
CREATE PROCEDURE [ara_ws].[PazientiAggiorna]
(
@Identity VARCHAR(64)
,@IdPaziente uniqueidentifier	    -- IDSAC del record paziente da aggiornare	
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
-------------------------------------------------------
, @PazientiEsenzioni AS ara.ParamPazientiEsenzioni READONLY
--, @PazientiConsensi AS ara.ParamPazientiConsensi READONLY
-------------------------------------------------------
)
AS
BEGIN
	DECLARE @NotificaAnagraficaDaEseguire BIT = 0
	--
	-- Imposto il livello di attendibilità per ARA (potrebbe essere un parametro di configurazione??)
	-- e il nome della Provenienza per ARA
	--
	DECLARE @LivelloAttendibilita TINYINT
	DECLARE @Provenienza varchar(16)
	--
	--
	--
	DECLARE @MsgEvento AS varchar(250)
	DECLARE @MsgIstat AS varchar(64)
	DECLARE @Msg AS varchar(500)
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
	DECLARE @RaiseErrorMsg VARCHAR(128)
	SET NOCOUNT ON;
	SET @NotificaAnagraficaDaEseguire = 0

	--
	-- Inizio controlli
	--
	SELECT @LivelloAttendibilita = ValoreInt FROM ara.Config WHERE Nome = 'LivelloAttendibilita'
	IF @LivelloAttendibilita IS NULL 
	BEGIN
		RAISERROR('Il @LivelloAttendibilita per ARA non è valorizzato. Vedi tabella ara.Config.', 16, 1)
		RETURN
	END

	SELECT @Provenienza = ValoreString FROM ara.Config WHERE Nome = 'Provenienza'
	IF ISNULL(@Provenienza, '') = '' 
	BEGIN
		RAISERROR('La @Provenienza per ARA non è valorizzata. Vedi tabella ara.Config.', 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Controllo Codice Fiscale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		SET @RaiseErrorMsg = 'Errore durante ' + @ProcName + ', il campo CodiceFiscale è vuoto!'
		RAISERROR(@RaiseErrorMsg , 16, 1)
		RETURN
	END

	---------------------------------------------------
	--	Verifica incoerenza Istat
	---------------------------------------------------
	DECLARE @IstatErrorMessage VARCHAR(128)
	DECLARE @IstatErrorCode INT
	SELECT @ComuneNascitaCodice = dbo.NormalizzaCodiceIstatComune(@ComuneNascitaCodice)
	SELECT @ComuneResCodice = dbo.NormalizzaCodiceIstatComune(@ComuneResCodice)
	SELECT @ComuneDomCodice = dbo.NormalizzaCodiceIstatComune(@ComuneDomCodice)
	SELECT @IstatErrorCode = dbo.GetErroreIncoerenzaIstat(@ComuneNascitaCodice, @ComuneResCodice, @ComuneDomCodice, @DataNascita)
	SELECT @IstatErrorMessage = dbo.LookUpIstatErrorCode(@IstatErrorCode)
	IF @IstatErrorCode > 0 
	BEGIN
		RAISERROR(@IstatErrorMessage , 16,1)
		RETURN
	END
	
	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRANSACTION 
	BEGIN TRY
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
				SET @RaiseErrorMsg = 'Errore durante ' + @ProcName + + ', il valore del campo [@PosizioneAss] non è presente nella tabella PazientiPosizioneAss!' 
				RAISERROR(@RaiseErrorMsg , 16, 1)
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


		--
		-- Verifico esistenza del record nel SAC
		--
		IF NOT EXISTS (SELECT * FROM dbo.Pazienti WHERE Id = @IdPaziente)
		BEGIN 
			---------------------------------------------------
			-- Inserimento record
			---------------------------------------------------
			INSERT INTO dbo.Pazienti ( Id,Provenienza,IdProvenienza,DataInserimento,DataModifica,DataSequenza,LivelloAttendibilita,Tessera,Cognome,Nome,DataNascita,Sesso
					,ComuneNascitaCodice,NazionalitaCodice,CodiceFiscale,MantenimentoPediatra,CapoFamiglia,Indigenza,CodiceTerminazione,DescrizioneTerminazione
					,ComuneResCodice,SubComuneRes,IndirizzoRes,LocalitaRes,CapRes,DataDecorrenzaRes,CodiceAslRes,ComuneDomCodice,SubComuneDom
					,IndirizzoDom,LocalitaDom,CapDom,PosizioneAss,CodiceAslAss,DataInizioAss,DataScadenzaAss,DataTerminazioneAss,DistrettoAmm,DistrettoTer
					,Ambito,CodiceMedicoDiBase,CodiceFiscaleMedicoDiBase,CognomeNomeMedicoDiBase,DistrettoMedicoDiBase,DataSceltaMedicoDiBase,ComuneRecapitoCodice
					,IndirizzoRecapito,LocalitaRecapito,Telefono1,Telefono2,Telefono3,CodiceSTP,DataInizioSTP,DataFineSTP,MotivoAnnulloSTP,RegioneResCodice,RegioneAssCodice,Attributi )  	
				VALUES
					(@IdPaziente ,@Provenienza,@IdProvenienza, GETDATE() ,GETDATE() ,GETDATE() ,@LivelloAttendibilita ,@Tessera ,@Cognome, @Nome, @DataNascita
					,@Sesso,ISNULL(@ComuneNascitaCodice, '000000'),@NazionalitaCodice,@CodiceFiscale,@MantenimentoPediatra,@CapoFamiglia,@Indigenza,@CodiceTerminazione
					,@DescrizioneTerminazione,@ComuneResCodice,@SubComuneRes,@IndirizzoRes,@LocalitaRes,@CapRes,@DataDecorrenzaRes,@CodiceAslRes,@ComuneDomCodice,@SubComuneDom
					,@IndirizzoDom,@LocalitaDom,@CapDom,@PosizioneAss,@CodiceAslAss,@DataInizioAss,@DataScadenzaAss,@DataTerminazioneAss,@DistrettoAmm,@DistrettoTer,@Ambito
					,@CodiceMedicoDiBase,@CodiceFiscaleMedicoDiBase,@CognomeNomeMedicoDiBase,@DistrettoMedicoDiBase,@DataSceltaMedicoDiBase,@ComuneRecapitoCodice
					,@IndirizzoRecapito,@LocalitaRecapito,@Telefono1,@Telefono2,@Telefono3,@CodiceSTP,@DataInizioSTP,@DataFineSTP,@MotivoAnnulloSTP,@RegioneResCodice
					,@RegioneAssCodice,@Attributi 
				)
			
			---------------------------------------------------
			-- Inserisce record d'evento
			---------------------------------------------------
			IF LEN(@Msg) > 35
			BEGIN
				SET @Msg = @Msg + @MsgEvento
				EXEC dbo.PazientiEventiAvvertimento @Identity, 0, @ProcName, @Msg
			END

			SET @NotificaAnagraficaDaEseguire = 1
		END
		ELSE
		BEGIN
			---------------------------------------------------
			-- Aggiornamento record
			---------------------------------------------------
			--Verifico che i dati del record siano effettivamente cambiati
			DECLARE @Checksum_OLD INT 
			DECLARE @Checksum_NEW INT 
			SELECT @Checksum_OLD  = CHECKSUM(Provenienza,IdProvenienza,LivelloAttendibilita,Tessera,Cognome,Nome,DataNascita,Sesso
					,ComuneNascitaCodice,NazionalitaCodice,CodiceFiscale,MantenimentoPediatra,CapoFamiglia,Indigenza,CodiceTerminazione,DescrizioneTerminazione
					,ComuneResCodice,SubComuneRes,IndirizzoRes,LocalitaRes,CapRes,DataDecorrenzaRes,CodiceAslRes,ComuneDomCodice,SubComuneDom
					,IndirizzoDom,LocalitaDom,CapDom,PosizioneAss,CodiceAslAss,DataInizioAss,DataScadenzaAss,DataTerminazioneAss,DistrettoAmm,DistrettoTer
					,Ambito,CodiceMedicoDiBase,CodiceFiscaleMedicoDiBase,CognomeNomeMedicoDiBase,DistrettoMedicoDiBase,DataSceltaMedicoDiBase,ComuneRecapitoCodice
					,IndirizzoRecapito,LocalitaRecapito,Telefono1,Telefono2,Telefono3,CodiceSTP,DataInizioSTP,DataFineSTP,MotivoAnnulloSTP,RegioneResCodice,RegioneAssCodice,CAST(Attributi AS VARCHAR(MAX)))
					FROM dbo.Pazienti WHERE Id = @IdPaziente

			SELECT @Checksum_NEW  = CHECKSUM(@Provenienza,@IdProvenienza,@LivelloAttendibilita,@Tessera,@Cognome,@Nome,@DataNascita,@Sesso
					,@ComuneNascitaCodice,@NazionalitaCodice,@CodiceFiscale,@MantenimentoPediatra,@CapoFamiglia,@Indigenza,@CodiceTerminazione,@DescrizioneTerminazione
					,@ComuneResCodice,@SubComuneRes,@IndirizzoRes,@LocalitaRes,@CapRes,@DataDecorrenzaRes,@CodiceAslRes,@ComuneDomCodice,@SubComuneDom
					,@IndirizzoDom,@LocalitaDom,@CapDom,@PosizioneAss,@CodiceAslAss,@DataInizioAss,@DataScadenzaAss,@DataTerminazioneAss,@DistrettoAmm,@DistrettoTer
					,@Ambito,@CodiceMedicoDiBase,@CodiceFiscaleMedicoDiBase,@CognomeNomeMedicoDiBase,@DistrettoMedicoDiBase,@DataSceltaMedicoDiBase,@ComuneRecapitoCodice
					,@IndirizzoRecapito,@LocalitaRecapito,@Telefono1,@Telefono2,@Telefono3,@CodiceSTP,@DataInizioSTP,@DataFineSTP,@MotivoAnnulloSTP,@RegioneResCodice,@RegioneAssCodice,CAST(@Attributi AS VARCHAR(MAX)))

			IF @Checksum_OLD <> @Checksum_NEW 
			BEGIN 
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
					-- Riattivazione anagrafiche cancellate logicamente
					-- Aggiornamento del campo Disattivato:
					--		Se Disattivato = 0 (ATTIVO) o 2(FUSO) deve rimanere tale
					--		Se Disattivato = 1 (CANCELLATO) deve diventare 0 (ATTIVO)
					-- Affinchè funzioni ce ne deve essere uno solo di record con [Provenienza, IdProvenienza]=[@Provenienza, @IdProvenienza]
					--
					, Disattivato = CASE WHEN Disattivato = 1 THEN 0 
									ELSE Disattivato END 
					, DataDisattivazione = CASE WHEN Disattivato = 1 THEN NULL 
									ELSE DataDisattivazione END
				WHERE Id = @IdPaziente
			
			---------------------------------------------------
			-- Inserisce record d'evento
			---------------------------------------------------
			IF LEN(@Msg) > 35
			BEGIN
				SET @Msg = @Msg + @MsgEvento
				EXEC dbo.PazientiEventiAvvertimento @Identity, 0, @ProcName, @Msg
			END

				SET @NotificaAnagraficaDaEseguire = 1
			END
			ELSE
			BEGIN 
				--
				-- Anche se non aggiorno i dati del paziente aggiorno la DataModifica, così il record non verrà più inserito nella coda alla prossima lettura
				--
				UPDATE dbo.Pazienti
					SET DataModifica = GETDATE()					 
				WHERE Id = @IdPaziente
				
			END 

		END

		---------------------------------------------------------------------------------------
		-- Inserimento delle esenzioni
		---------------------------------------------------------------------------------------
		DECLARE @NotificaAnagraficaDaEseguireEsenzioni BIT = 0
		EXEC [ara_ws].[PazientiEsenzioniAggiorna] @Identity , @IdPaziente, @PazientiEsenzioni, @NotificaAnagraficaDaEseguireEsenzioni 

		--DECLARE @NotificaAnagraficaDaEseguireConsensi BIT = 0
		--EXEC [ara_ws].[PazientiConsensiAggiorna] @Identity , @IdPaziente, @PazientiConsensi, @NotificaAnagraficaDaEseguireConsensi 

		IF @NotificaAnagraficaDaEseguire = 1 OR @NotificaAnagraficaDaEseguireEsenzioni = 1 --OR @NotificaAnagraficaDaEseguireConsensi = 1
		BEGIN 
			--
			-- Eseguo la notifica
			--
			---------------------------------------------------
			-- Inserisce record di notifica
			---------------------------------------------------
			EXEC dbo.PazientiNotificheAdd @IdPaziente, '2', @Identity
		END


		--
		--
		--
		COMMIT

	END TRY
	BEGIN CATCH
		---------------------------------------------------
		--     ROLLBACK TRANSAZIONE
		---------------------------------------------------
		IF @@TRANCOUNT > 0 ROLLBACK

		SET @NotificaAnagraficaDaEseguire = 0
		---------------------------------------------------
		--     GESTIONE ERRORI (LOG E PASSO FUORI)
		---------------------------------------------------
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE()    
		EXEC dbo.PazientiEventiErrore @Identity , 0, @ProcName, @ErrMsg
		-- PASSO FUORI L'ECCEZIONE
		;THROW;

	END CATCH

END