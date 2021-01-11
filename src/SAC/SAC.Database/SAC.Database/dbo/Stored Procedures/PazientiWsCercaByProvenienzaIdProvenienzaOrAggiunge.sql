
-- =============================================
-- Creation date: ???
-- Author: ???
-- Modify date: 27/03/2012
-- Modify date: Ettore 2012-12-03: aggiunto merge al volo
-- Modify date: Ettore 2012-12-11: aggiunta possibilità di eseguire il merge anche di notte, bypassando il controllo di fascia oraria
-- Modify date: ETTORE 2018-07-18: gestione delle anagrafiche che possono essere fuse automaticamente (per gestione provenienza HPV)
-- Description:	Cerca una anagrafica e se non la trova la inserisce ed eventualmente la fonde
-- Modify date: ETTORE 2019-02-15: Controllo i campi obbligatori [Cognome, Nome, ComuneNascitaCodice, CodiceFiscale] per l'inserimento anagrafico
--									nella SP solo nel caso in cui si debba fare l'inserimento
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
-- Modify date: 2020-08-28: Ettore - PROBLEMA: 
--									se si cerca l'anagrafica [@Provenienza, @IdProvenienza] con @Provenienza <> @ProvenienzaIdentity si può verificare, 
--									se l'anagrafica cercata [@Provenienza, @IdProvenienza] non esiste, di restituire, nel caso esista già, una anagrafica 
--									[@ProvenienzaIdentity, @IdProvenienza] che corrisponde ad una persona diversa da quella cercata.
--									CORREZIONE: 
--									se il parametro @Provenienza (=@ProvenienzaRicerca) <> @ProvenienzaIdentity in caso di creazione di una 
--									nuova anagrafica viene calcolato un nuovo @IdProvenienza=@IdProvenienza + '@' + @ProvenienzaRicerca.
-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge]
(
	  @Identity varchar(64)

	, @Provenienza varchar(16)			--provenienza da usare nella fase di ricerca della posizione
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
) WITH RECOMPILE
AS  
BEGIN
DECLARE @Id uniqueidentifier
DECLARE @DataSequenza datetime
DECLARE @ProvenienzaIdentity AS varchar(16) --la provenienza del chiamante corrente che verrà usata anche per l'inserimento

	SET NOCOUNT ON;

	-- Controllo accesso
	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge', 'Utente non ha i permessi di lettura!'
		RAISERROR('Errore di controllo accessi durante PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge!', 16, 1)
		RETURN
	END

	-- Calcolo provenienza dall'@Identity che verrà usata in fase di inserimento della posizione
	SET @ProvenienzaIdentity  = dbo.LeggePazientiProvenienza(@Identity)
	IF @ProvenienzaIdentity  IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge!', 16, 1)
		RETURN
	END			
	
	BEGIN TRY
				
		-- Cerco il paziente per @Provenienza/@IdProvenienza passati come parametri
		SELECT TOP 1 @Id = Id 
		FROM PazientiDettaglioResult
		WHERE
			(
				(Provenienza = @Provenienza	AND IdProvenienza = @IdProvenienza)
				OR (PazientiDettaglioResult.Id IN(
						SELECT PazientiSinonimi.IdPaziente
						FROM PazientiSinonimi
						WHERE 
								PazientiSinonimi.Provenienza = @Provenienza
							AND PazientiSinonimi.IdProvenienza = @IdProvenienza
							AND Abilitato = 1
						)
					)
			)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaIdentity) AS TAB 
				WHERE TAB.Provenienza = PazientiDettaglioResult.Provenienza
				)
		ORDER BY
			StatusCodice
		
		PRINT 'Step 1) Ricerca per provenienza/idprovenienza di ricerca: @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')

		-- Se non trovo il paziente lo inserisco: prima devo verificare che non esista una posizione con @ProvenienzaIdentity/@IdProvenienza
		IF @Id IS NULL
		BEGIN
			-- Cerco per @ProvenienzaIdentity solo se diversa da @Provenienza per evitare una query in più
			IF @ProvenienzaIdentity <> @Provenienza
			BEGIN
				-- Modify date: 2020-08-28: imposto @IdProvenienza per la fase successiva di creazione 
				SET @IdProvenienza = @IdProvenienza + '@' + @Provenienza

				-- Verifico che la posizione che voglio inserire non esista già
				-- Ricerco per @ProvenienzaIdentity/@IdProvenienza
				SELECT TOP 1 @Id = Id 
				FROM PazientiDettaglioResult
				WHERE
					(
						(Provenienza = @ProvenienzaIdentity AND IdProvenienza = @IdProvenienza)
						OR (PazientiDettaglioResult.Id IN(
								SELECT PazientiSinonimi.IdPaziente
								FROM PazientiSinonimi
								WHERE 
										PazientiSinonimi.Provenienza = @ProvenienzaIdentity
									AND PazientiSinonimi.IdProvenienza = @IdProvenienza
									AND Abilitato = 1
								)
							)
					)
					AND  EXISTS(
						SELECT * 
						FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaIdentity) AS TAB 
						WHERE TAB.Provenienza = PazientiDettaglioResult.Provenienza
						)
				ORDER BY
					StatusCodice
			END

			PRINT 'Step 2) Ricerca per provenienzadaidentity/idprovenienza di ricerca: @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')
			
			IF @Id IS NULL
			BEGIN

				PRINT 'Step 3) inizio step per inserimento'
		
				IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
				BEGIN
					EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge', 'Utente non ha i permessi di scrittura!'

					RAISERROR('Errore di controllo accessi durante PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge!', 16, 1)
					RETURN
				END

				--
				-- ETTORE 2019-02-15: Controllo i campi obbligatori [Cognome, Nome, ComuneNascitaCodice, CodiceFiscale] per l'inserimento anagrafico
				--
				IF ISNULL(@Cognome, '') = '' 
				BEGIN 
					RAISERROR('Campo obbligatorio mancante. Parameter name: Cognome', 16, 1)
					RETURN
				END
				IF ISNULL(@Nome, '') = '' 
				BEGIN 
					RAISERROR('Campo obbligatorio mancante. Parameter name: Nome', 16, 1)
					RETURN
				END
				IF ISNULL(@ComuneNascitaCodice, '') = '' 
				BEGIN 
					RAISERROR('Campo obbligatorio mancante. Parameter name: ComuneNascitaCodice', 16, 1)
					RETURN
				END
				IF ISNULL(@CodiceFiscale, '') = '' 
				BEGIN 
					RAISERROR('Campo obbligatorio mancante. Parameter name: CodiceFiscale', 16, 1)
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

					PRINT 'Step 4) Eseguito inserimento @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')

					--
					--	MODIFICA ETTORE 2018-07-18: gestione delle anagrafiche che possono essere fuse automaticamente (per gestione provenienza HPV)
					--
					IF dbo.IsAnagraficaDaFondereAutomaticamente (@ProvenienzaIdentity) = 1
					BEGIN 													

						PRINT 'Step 5) Anagrafica da fondere automaticamente'
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
									, @ProvenienzaFuso = @ProvenienzaIdentity --devo inserire per la provenienza di inserimento ricavata dall'Identity
									, @IdProvenienzaFuso = @IdProvenienza
									, @Motivo = 1						--0=Dipartimentale; 1=Input merge CF; 2=Batch merge CF; 3=UI
									, @Note = 'Merge eseguita da PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge'
							--
							-- Modifica Ettore 2013-03-19: uso nuovo Tipo=6 come per i WS visto che l'inserimento viene fatto con PazientiWsBaseInsert2
							--
							EXEC PazientiNotificheAdd @Id, 6, @Identity --0=Msg; 1= UI; 2=WS; 3=Batch;4=Msg-notifica merge;5=UI-notifica merge; 6=ws-merge 
							--
							-- Se sono qui il merge è stato eseguito imposto il padre come Id da restituire
							-- perchè devo restituire il paziente attivo
							--
							SET @Id = @IdPazientePadre

							PRINT 'Step 6) IdPaziente ROOT @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')
						END
					END
													
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
		-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
		--
		UPDATE dbo.Pazienti
			SET DataUltimoUtilizzo = GETDATE()
		WHERE Id = @Id

		PRINT 'Step 7) IdPaziente restituito @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')
	
		-- Return
		SELECT @Id AS Id

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(4000)
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
    ON OBJECT::[dbo].[PazientiWsCercaByProvenienzaIdProvenienzaOrAggiunge] TO [DataAccessWs]
    AS [dbo];

