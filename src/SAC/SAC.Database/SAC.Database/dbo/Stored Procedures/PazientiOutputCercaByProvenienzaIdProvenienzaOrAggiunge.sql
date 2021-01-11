




-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date:	ETTORE 2014-04-25:
--		1) Normalizzazione dei codici istat dei comuni
--		2) Gestione dell'incoerenza istat dei comuni. Se codici istat dei comuni sono incoerenti genero una eccezione 
-- Modify date: ETTORE 2014-07-07: 
--		Modifica per disaccoppiare la SP dalla SP dei WS PazientiWsDettaglioByIdProvenienza
--		Uso nuova FUNCTION GetPazienteByProvenienzaIdProvenienza() che restituisce l'IdPaziente
-- Modify date: ETTORE 2016-05-26: Rimosso controllo accesso di lettura
-- Modify date: ETTORE 2018-07-18: gestione delle anagrafiche che possono essere fuse automaticamente (per gestione provenienza HPV)
-- Modify date: ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
-- Modify date: 2020-08-28: Ettore - PROBLEMA: 
--									se si cerca l'anagrafica [@Provenienza, @IdProvenienza] con @Provenienza <> @ProvenienzaIdentity si può verificare, 
--									se l'anagrafica cercata [@Provenienza, @IdProvenienza] non esiste, di restituire, nel caso esista già, una anagrafica 
--									[@ProvenienzaIdentity, @IdProvenienza] che corrisponde ad una persona diversa da quella cercata.
--									CORREZIONE: 
--									se il parametro @Provenienza (=@ProvenienzaRicerca) <> @ProvenienzaIdentity in caso di creazione di una 
--									nuova anagrafica viene calcolato un nuovo @IdProvenienza=@IdProvenienza + '@' + @ProvenienzaRicerca.
-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
-- Description:	Cerca una anagrafica e se non la trova la inserisce ed eventualmente la fonde
--				Utilizzata del servizio NT del CUP in sostituzione della PazientiOutputCercaOrAggiunge
--
-- ATTENZIONE: E' stata creata una nuova function 'dbo.GetErroreIncoerenzaIstat()' da usare al posto dei test sui vari comuni.
--		E' stata usata solo nella SP PazientiOutputCercaAggancioPaziente per risolvere problema NESTED EXEC INSERT 
--		quando richiamata dalle manteinance di aggancio del DWH nel caso di creazione del record paziente. 
--		FAREMO LA MODIFICA ALLA PRIMA OCCASIONE ANCHE IN QUESTA SP
--
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputCercaByProvenienzaIdProvenienzaOrAggiunge]
(
	  @Provenienza varchar(16)	--provenienza utilizzata in fase di ricerca della posizione
	, @IdProvenienza varchar(64)
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
	DECLARE @Id uniqueidentifier
	DECLARE @DataSequenza datetime
	DECLARE @IdPaziente UNIQUEIDENTIFIER

	SET NOCOUNT ON;

	-- Controllo accesso
	SET @Identity = USER_NAME()
		
	BEGIN TRY
		--
		-- Cerco il paziente per provenienza di ricerca (@Provenienza) e IdProvenienza (@IdProvenienza)
		--
		SELECT @IdPaziente = [dbo].[GetPazienteByProvenienzaIdProvenienza] (@Provenienza, @IdProvenienza)
		--
		-- Verifico esistenza del paziente: se non esiste lo creo dopo avere verificato che non esista già una posizione 
		-- con @ProvenienzaDiInserimento (calcolata dall'Identity), @IdProvenienza
		--
		IF @IdPaziente IS NULL 
		BEGIN 
			-- Calcolo provenienza dall'@Identity
			DECLARE @ProvenienzaDiInserimento varchar(16)
			SET @ProvenienzaDiInserimento = dbo.LeggePazientiProvenienza(@Identity)
			IF @ProvenienzaDiInserimento IS NULL
			BEGIN
				RAISERROR('Errore di Provenienza non trovata durante PazientiOutputCercaByProvenienzaIdProvenienzaOrAggiunge!', 16, 1)
				RETURN
			END				
			
			-- Cerco per @ProvenienzaDiInserimento solo se diversa da @Provenienza per evitare una query in più
			IF @ProvenienzaDiInserimento <> @Provenienza
			BEGIN
				-- Modify date: 2020-08-28: imposto @IdProvenienza per la fase successiva di creazione 
				SET @IdProvenienza = @IdProvenienza + '@' + @Provenienza
				SELECT @IdPaziente = [dbo].[GetPazienteByProvenienzaIdProvenienza] (@ProvenienzaDiInserimento, @IdProvenienza)
			END
			
			-- Se non esiste lo creo
			IF @IdPaziente IS NULL 
			BEGIN
				IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
				BEGIN
					EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiOutputCercaByProvenienzaIdProvenienzaOrAggiunge', 'Utente non ha i permessi di scrittura!'
					RAISERROR('Errore di controllo accessi durante PazientiOutputCercaByProvenienzaIdProvenienzaOrAggiunge!', 16, 1)
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
					-- Questa inserirà con la stessa provenienza @ProvenienzaDiInserimento poichè internamente la deriva dall'@Identity
					EXEC dbo.PazientiWsBaseInsert2 @Identity, @DataSequenza, @Id, @IdProvenienza, @Tessera, @Cognome, @Nome, @DataNascita, @Sesso, 
													@ComuneNascitaCodice, @NazionalitaCodice, @CodiceFiscale, @ComuneResCodice, 
													@SubComuneRes, @IndirizzoRes, @LocalitaRes, @CapRes, @ComuneDomCodice, @SubComuneDom, 
													@IndirizzoDom, @LocalitaDom, @CapDom, @IndirizzoRecapito, @LocalitaRecapito, 
													@Telefono1, @Telefono2, @Telefono3
					--
					-- MODIFICA ETTORE 2016-07-18: Se l'anagrafica può essere fusa automaticamente procedo con la fusione al volo
					--
					IF dbo.IsAnagraficaDaFondereAutomaticamente (@ProvenienzaDiInserimento) = 1
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
									, @ProvenienzaFuso = @ProvenienzaDiInserimento --devo inserire per la provenienza di inserimento ricavata dall'Identity
									, @IdProvenienzaFuso = @IdProvenienza
									, @Motivo = 1						--0=Dipartimentale; 1=Input merge CF; 2=Batch merge CF; 3=UI
									, @Note = 'Merge eseguito da PazientiOutputCercaByProvenienzaIdProvenienzaOrAggiunge'
							--
							-- Modifica Ettore 2013-03-19: uso nuovo Tipo=6 come per i WS visto che l'inserimento viene fatto con PazientiWsBaseInsert2
							--
							EXEC PazientiNotificheAdd @Id, 6, @Identity --0=Msg; 1= UI; 2=WS; 3=Batch;4=Msg-notifica merge;5=UI-notifica merge; 6=ws-merge 
							--
							-- Se sono qui il merge è stato eseguito 
							--
						END
					END
													
					--Restituisco la posizione appena inserita per Provenienza di inserimento
					SELECT @IdPaziente = [dbo].[GetPazienteByProvenienzaIdProvenienza] (@ProvenienzaDiInserimento, @IdProvenienza)
					
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
		-- MODIFICA ETTORE 2016-10-27: A questo punto @IdPaziente è ATTIVO
		--
		DECLARE @DataDecesso DATETIME 
		IF NOT @IdPaziente IS NULL
		BEGIN
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)	
		END 
			
		--
		-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
		--
		UPDATE dbo.Pazienti
			SET DataUltimoUtilizzo = GETDATE()
		WHERE Id = @IdPaziente 

		-- A questo punto restituisco i dati associati ad @IdPaziente
		SELECT  Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
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
		  FROM dbo.PazientiDettaglioResult
		  WHERE Id = @IdPaziente
		
	
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
    ON OBJECT::[dbo].[PazientiOutputCercaByProvenienzaIdProvenienzaOrAggiunge] TO [DataAccessSql]
    AS [dbo];

