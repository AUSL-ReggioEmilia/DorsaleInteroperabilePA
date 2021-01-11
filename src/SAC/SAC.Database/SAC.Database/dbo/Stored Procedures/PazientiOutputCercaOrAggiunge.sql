


-- =============================================
-- Author:		???
-- Create date: ???
--		Questa SP era inizialmente utilizzata dal servizio NT del CUP.
-- Modify date: ETTORE 2014-04-25: 
--				1) Normalizzazione dei codici istat dei comuni
--				2) Gestione dell'incoerenza istat dei comuni. Se codici istat dei comuni sono incoerenti genero una eccezione 
-- Modify date: ETTORE 2014-07-07: 
				--Disaccoppio questa SP dalla SP WS PazientiWsdettaglioByIdProvenienza 
--				usando la NUOVA funzione dbo.GetPazienteByProvenienzaIdProvenienza() per cercare l'IdPaziente
-- Modify date: SANDRO 2016-05-26 Rimosso controllo accesso di lettura
-- Modify date: ETTORE 2018-07-18: gestione delle anagrafiche che possono essere fuse automaticamente (per gestione provenienza HPV)
-- Modify date: 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
--							Sistemata la parte per il calcolo della ProvenienzaRicerca: inizializzo @ProvenienzaRicerca con la @Provenienza derivata dall'utente
--							Commentata la parte di valorizzazione della @ProvenienzaRicerca tramite l'identity
-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
-- Description:	Cerca una anagrafica e se non la trova la inserisce ed eventualmente la fonde
--
-- ATTENZIONE: La SP è OBSOLETA. In seguito a trace su SQL SERVER fatto il 2016-11-08 nessuno per una giornata l'ha usata
--
--
-- ATTENZIONE: E' stata creata una nuova function 'dbo.GetErroreIncoerenzaIstat()' da usare al posto dei test sui vari comuni.
--		E' stata usata solo nella SP PazientiOutputCercaAggancioPaziente per risolvere problema NESTED EXEC INSERT 
--		quando richiamata dalle manteinance di aggancio del DWH nel caso di creazione del record paziente. 
--		FAREMO LA MODIFICA ALLA PRIMA OCCASIONE ANCHE IN QUESTA SP
--
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputCercaOrAggiunge]
(
	  @IdProvenienza varchar(64)
	, @Tessera varchar(16) = null
	, @Cognome varchar(64) = null
	, @Nome varchar(64) = null
	, @DataNascita datetime = null
	, @Sesso varchar(1) = null
	, @ComuneNascitaCodice varchar(6) = null
	, @NazionalitaCodice varchar(3) = null
	, @CodiceFiscale varchar(16) = null
	
	, @ComuneResCodice varchar(6) = null
	, @SubComuneRes varchar(64) = null
	, @IndirizzoRes varchar(256) = null
	, @LocalitaRes varchar(128) = null
	, @CapRes varchar(8) = null

	, @ComuneDomCodice varchar(6) = null
	, @SubComuneDom varchar(64) = null
	, @IndirizzoDom varchar(256) = null
	, @LocalitaDom varchar(128) = null
	, @CapDom varchar(8) = null
	
	, @IndirizzoRecapito varchar(256) = null
	, @LocalitaRecapito varchar(128) = null
	, @Telefono1 varchar(20) = null
	, @Telefono2 varchar(20) = null
	, @Telefono3 varchar(20) = null
)
AS
BEGIN
	DECLARE @Identity varchar(64)
	DECLARE @Provenienza varchar(16)
	DECLARE @Id uniqueidentifier
	DECLARE @DataSequenza datetime
	DECLARE @IdPaziente UNIQUEIDENTIFIER

	SET NOCOUNT ON;

	-- Controllo accesso
	SET @Identity = USER_NAME()
	
	BEGIN TRY
	
		--
		-- MODIFICA ETTORE 2012-03-27 PER RISOLVERE AL VOLO LA RICERCA PER PROVENIENZA ERRATA
		-- SI DEVE CERCARE PER UNA PROVENIENZA (che dovrebbe essere passata come parametro 
		-- e si deve inserire con la provenienza derivata dal parametro @Identity)
		--
		DECLARE @ProvenienzaRicerca varchar(16)
		-----------------------------------------------------------------------------------------------------
		-- Ricavo la provenienza di ricerca: dall'identity passo alla provenienza con cui devo ricercare
		-----------------------------------------------------------------------------------------------------
		-- Calcolo provenienza da utente
		SET @Provenienza = dbo.LeggePazientiProvenienza(@Identity)
		IF @Provenienza IS NULL
		BEGIN
		
			RAISERROR('Errore di Provenienza non trovata durante PazientiOutputCercaOrAggiunge!', 16, 1)
			RETURN
		END
		--
		-- Inizializzo @ProvenienzaRicerca	
		--
		SET @ProvenienzaRicerca	= @Provenienza
		
		--MODIFICA ETTORE 2016-11-08: questi utenti hanno associate le stesse provenienze su SAC, quindi questo pezzo di codice è inutile
		--IF @Identity = 'OSPEDALE\SVC_OE_CUP_AS400' Or @Identity = 'SVC_OE_CUP_AS400@asmn.net'
		--BEGIN
		--	SET @ProvenienzaRicerca = 'LHA'
		--	-- IL CUP invia gli IdProvenienza di LHA padded con degli 0 a sinistra: li rimuovo
		--	SET @IdProvenienza = REPLACE(LTRIM(REPLACE(@idProvenienza , '0', ' ')), ' ', '0')
		--END
		--ELSE IF @Identity = 'SAC_GST_AUSL' Or @Identity = 'OSPEDALE\APP_SAC-LIS-AUSL'
		--BEGIN
		--	SET @ProvenienzaRicerca = 'GST_AUSL'
		--END
		--ELSE IF @Identity = 'SAC_GST_ASMN' Or @Identity = 'OSPEDALE\APP_SAC-GSTOE-ELCO' 
		--BEGIN
		--	SET @ProvenienzaRicerca = 'GST_ASMN'
		--END

		--
		-- Cerco il paziente per @ProvenienzaRicerca/@Idprovenienza
		--
		SELECT @IdPaziente = dbo.GetPazienteByProvenienzaIdProvenienza(@ProvenienzaRicerca, @IdProvenienza)
		--	
		-- Verifico esistenza del paziente: se non esiste lo creo
		--
		IF @IdPaziente IS NULL 
		BEGIN 
			--
			-- MODIFICA ETTORE: devo verificare se esiste la posizione che si vuole inserire con la provenienza letta dall'@Identity
			--
			SELECT @IdPaziente = dbo.GetPazienteByProvenienzaIdProvenienza(@Provenienza, @IdProvenienza)
			
			IF @IdPaziente IS NULL 
			BEGIN 
				IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
				BEGIN
					EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiOutputCercaOrAggiunge', 'Utente non ha i permessi di scrittura!'

					RAISERROR('Errore di controllo accessi durante PazientiOutputCercaOrAggiunge!', 16, 1)
					RETURN
				END
				---------------------------------------------------
				-- MODIFICA ETTORE 2014-04-25:
				--			Normalizzazione dei codici ISTAT dei comuni
				---------------------------------------------------
				SELECT @ComuneNascitaCodice = dbo.NormalizzaCodiceIstatComune(@ComuneNascitaCodice)
				SELECT @ComuneResCodice = dbo.NormalizzaCodiceIstatComune(@ComuneResCodice)
				SELECT @ComuneDomCodice = dbo.NormalizzaCodiceIstatComune(@ComuneDomCodice)
				---------------------------------------------------
				-- MODIFICA ETTORE 2014-04-25: 
				--			Verifica incoerenza Istat
				---------------------------------------------------
				DECLARE @IstatErrorMessage VARCHAR(128)
				DECLARE @IstatErrorCode INT
				DECLARE @TableIstatErrorCode AS TABLE (ERROR_CODE INTEGER)
				INSERT INTO @TableIstatErrorCode (ERROR_CODE )
				EXECUTE IstatWsIncoerenzaIstatVerifica @Identity, @ComuneNascitaCodice, @ComuneResCodice, @ComuneDomCodice, @DataNascita
				SELECT @IstatErrorCode = ERROR_CODE  FROM @TableIstatErrorCode 
				SELECT @IstatErrorMessage = dbo.LookUpIstatErrorCode(@IstatErrorCode)
				IF @IstatErrorCode > 0 
				BEGIN
					RAISERROR(@IstatErrorMessage , 16,1)
					RETURN
				END

				BEGIN TRANSACTION
				BEGIN TRY
					SET @Id = newid()
					SET @DataSequenza = '1753-01-01'
					
					EXEC dbo.PazientiWsBaseInsert2 @Identity, @DataSequenza, @Id, @IdProvenienza, @Tessera, @Cognome, @Nome, @DataNascita, @Sesso, 
													@ComuneNascitaCodice, @NazionalitaCodice, @CodiceFiscale, @ComuneResCodice, 
													@SubComuneRes, @IndirizzoRes, @LocalitaRes, @CapRes, @ComuneDomCodice, @SubComuneDom, 
													@IndirizzoDom, @LocalitaDom, @CapDom, @IndirizzoRecapito, @LocalitaRecapito, 
													@Telefono1, @Telefono2, @Telefono3

					--
					--	MODIFICA ETTORE 2018-07-18: gestione delle anagrafiche che possono essere fuse automaticamente (per gestione provenienza HPV)
					--
					IF dbo.IsAnagraficaDaFondereAutomaticamente (@Provenienza) = 1
					BEGIN 													
						--
						-- Cerco candidato padre
						--
						DECLARE @IdPazientePadre UNIQUEIDENTIFIER
						EXEC  dbo.PazientiFusioniOttieniCandidatoPadre  
									@IdPazDaFondere	= @Id
									, @IdPazientePadre = @IdPazientePadre OUTPUT
						IF NOT @IdPazientePadre IS NULL
						BEGIN
							EXEC PazientiBaseMerge
									  @IdPaziente = @IdPazientePadre
									, @IdPazienteFuso = @Id
									, @ProvenienzaFuso = @Provenienza --devo inserire per la provenienza di inserimento ricavata dall'Identity
									, @IdProvenienzaFuso = @IdProvenienza
									, @Motivo = 1						--0=Dipartimentale; 1=Input merge CF; 2=Batch merge CF; 3=UI
									, @Note = 'Merge eseguita da PazientiOutputCercaOrAggiunge'
							--
							-- Modifica Ettore 2013-03-19: uso nuovo Tipo=6 come per i WS visto che l'inserimento viene fatto con PazientiWsBaseInsert2
							--
							EXEC PazientiNotificheAdd @Id, 6, @Identity --0=Msg; 1= UI; 2=WS; 3=Batch;4=Msg-notifica merge;5=UI-notifica merge; 6=ws-merge 
							--
							-- Se sono qui il merge è stato eseguito 
							--
						END
					END
													
					--A questo punto cerco il record attivo corrispondente
					SELECT @IdPaziente = [dbo].[GetPazienteByProvenienzaIdProvenienza] (@Provenienza, @IdProvenienza)
					
					-- Commit della transazione	
					COMMIT
					
				END TRY
				BEGIN CATCH
					-- Rollback della transazione
					ROLLBACK
					
					DECLARE @Error varchar(4000)
					SELECT @Error =
						'ErrorNumber: ' + CONVERT(varchar(8), ERROR_NUMBER()) +
						', Severity: ' + CONVERT(varchar(8), ERROR_SEVERITY()) +
						', State: ' + CONVERT(varchar(8), ERROR_STATE()) + 
						', Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-') + 
						', Line: ' + CONVERT(varchar(8), ERROR_LINE()) +
						', Message: ' + ISNULL(ERROR_MESSAGE(), '-')
					RAISERROR(@Error, 16, 1)				
				END CATCH
			END 
		END
		--
		-- MODIFICA ETTORE 2016-10-27: A questo punto @IdPaziente è sempre il paziente attivo
		--
		DECLARE @DataDecesso DATETIME 
		IF NOT @IdPaziente IS NULL
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)

		--
		-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
		--
		UPDATE dbo.Pazienti
			SET DataUltimoUtilizzo = GETDATE()
		WHERE Id = @IdPaziente

		--
		-- A questo restituisco i dati dell'IdPaziente
		--
		SELECT  
				Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
			  , DataModifica, Tessera, Cognome, Nome, DataNascita, Sesso
			  , ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome
			  , NazionalitaCodice, NazionalitaNome, CodiceFiscale, DatiAnamnestici
			  , MantenimentoPediatra, CapoFamiglia, Indigenza
			  -- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT @DataDecesso IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
			  , CASE WHEN NOT @DataDecesso IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione
			  , ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
			  , IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes, ProvinciaAslResCodice, ProvinciaAslResNome
			  , ComuneAslResCodice, ComuneAslResNome, CodiceAslRes, RegioneResCodice, RegioneResNome
			  , ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom, IndirizzoDom
			  , LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome, ProvinciaAslAssCodice
			  , ProvinciaAslAssNome, ComuneAslAssCodice, ComuneAslAssNome, CodiceAslAss, DataInizioAss
			  , DataScadenzaAss
			  -- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT @DataDecesso IS NULL THEN @DataDecesso ELSE DataTerminazioneAss END AS DataTerminazioneAss
			  , DistrettoAmm, DistrettoTer, Ambito
			  , CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase
			  , DistrettoMedicoDiBase, DataSceltaMedicoDiBase, ComuneRecapitoCodice, ComuneRecapitoNome
			  , ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
			  , Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
			  , StatusCodice, StatusNome
		  FROM 
			dbo.PazientiDettaglioResult
		  WHERE 
			Id = @IdPaziente
		
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage =
			'ErrorNumber: ' + CONVERT(varchar(8), ERROR_NUMBER()) +
			', Severity: ' + CONVERT(varchar(8), ERROR_SEVERITY()) +
			', State: ' + CONVERT(varchar(8), ERROR_STATE()) + 
			', Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-') + 
			', Line: ' + CONVERT(varchar(8), ERROR_LINE()) +
			', Message: ' + ISNULL(ERROR_MESSAGE(), '-')
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputCercaOrAggiunge] TO [DataAccessSql]
    AS [dbo];

