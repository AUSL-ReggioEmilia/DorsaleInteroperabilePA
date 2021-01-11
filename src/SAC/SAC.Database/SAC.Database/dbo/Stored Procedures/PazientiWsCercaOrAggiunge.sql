






-- =============================================
-- Creation date: ???
-- Author: ???
-- Modify date: 28/02/2012
-- Modify date: ETTORE 2012-11-30: Aggiungiamo il merge dell'anagrafica appena inserita e restituiamo il padre
-- Modify date: ETTORE 2016-07-18: gestione delle anagrafiche che possono essere fuse automaticamente (per gestione provenienza HPV)
-- Modify date: ETTORE 2016-07-18: Commentata la parte di valorizzazione della @ProvenienzaRicerca tramite l'identity (@ProvenienzaRicerca era già inizializzata con la @Provenienza derivata dall'utente)
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
-- Description:	Cerca una anagrafica e se non la trova la inserisce ed eventualmente la fonde
-- ATTENZIONE: 
-- Questa stored procedure è stata costruita male: cerca e inserisce per lo stesso utente ricavato da USER_NAME()
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsCercaOrAggiunge]
(
	  @Identity varchar(64)

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
DECLARE @Provenienza varchar(16)
DECLARE @Id uniqueidentifier
DECLARE @DataSequenza datetime

	SET NOCOUNT ON;

	-- Controllo accesso
	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsCercaOrAggiunge', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsCercaOrAggiunge!', 16, 1)
		RETURN
	END

	-- Calcolo provenienza da utente
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Identity)
	IF @Provenienza IS NULL
	BEGIN
	
		RAISERROR('Errore di Provenienza non trovata durante PazientiWsCercaOrAggiunge!', 16, 1)
		RETURN
	END
	
	BEGIN TRY
		--
		-- MODIFICA ETTORE 2012-03-27 PER RISOLVERE AL VOLO LA RICERCA PER PROVENIENZA ERRATA
		-- SI DEVE CERCARE PER UA PROVENIENZA (che dovrebbe essere passata come parametro 
		-- e si deve inserire con la provenienza derivata dal parametro @Identity)
		--
		DECLARE @ProvenienzaRicerca varchar(16)
		-----------------------------------------------------------------------------------------------------
		-- Ricavo la provenienza di ricerca: dall'identity passo alla provenienza con cui devo ricercare
		-----------------------------------------------------------------------------------------------------
		--
		-- Inizializzo @ProvenienzaRicerca	
		--
		SET @ProvenienzaRicerca	= @Provenienza

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
		-- Cerco il paziente per @ProvenienzaRicerca/@idprovenienza
		-- MODIFICA ETTORE 2012-03-27 : ho usato @ProvenienzaRicerca invece di @Provenienza derivata dall'@Identity
		--
		SELECT TOP 1 @Id = Id 
		FROM PazientiDettaglioResult
		WHERE
			(
				(Provenienza = @ProvenienzaRicerca	AND IdProvenienza = @IdProvenienza)
				OR (PazientiDettaglioResult.Id IN(
						SELECT PazientiSinonimi.IdPaziente
						FROM PazientiSinonimi
						WHERE 
								PazientiSinonimi.Provenienza = @ProvenienzaRicerca
							AND PazientiSinonimi.IdProvenienza = @IdProvenienza
							AND Abilitato = 1
						)
					)
			)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@Provenienza) AS TAB 
				WHERE TAB.Provenienza = PazientiDettaglioResult.Provenienza
			)

		ORDER BY
			StatusCodice

		PRINT 'Step 1) Ricerca per idprovenienza di ricerca: @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')

		--	
		-- Se sono qui non ho trovato il paziente: lo inserisco
		--
		IF @Id IS NULL
		BEGIN
			--	
			-- MODIFICA ETTORE 2012-03-27: verifico che la posizione che si vuole inserire non esista già
			-- quindi cerco con la @provenienza derivata dall'@Identity
			--
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
					FROM dbo.OttieneProvenienzeRicercabiliWs(@Provenienza) AS TAB 
					WHERE TAB.Provenienza = PazientiDettaglioResult.Provenienza
				)
			ORDER BY
				StatusCodice	

			PRINT 'Step 2) Ricerca per provenienzadaidentity/idprovenienza di ricerca: @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')
				
			IF @Id IS NULL
			BEGIN
				IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
				BEGIN
					EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsCercaOrAggiunge', 'Utente non ha i permessi di scrittura!'

					RAISERROR('Errore di controllo accessi durante PazientiWsCercaOrAggiunge!', 16, 1)
					RETURN
				END
				
				BEGIN TRANSACTION
				BEGIN TRY
					PRINT 'Step 3) inizio step per inserimento'
					--
					-- Creo nuovo Id del record paziente
					--
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
					IF dbo.IsAnagraficaDaFondereAutomaticamente (@Provenienza) = 1
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
									, @ProvenienzaFuso = @Provenienza
									, @IdProvenienzaFuso = @IdProvenienza
									, @Motivo = 1						--0=Dipartimentale; 1=Input merge CF; 2=Batch merge CF; 3=UI
									, @Note = 'Merge eseguita da PazientiWsCercaOrAggiunge'
							--
							-- Modifica Ettore 2013-03-19: uso nuovo Tipo=6 come per i WS visto che l'inserimento viene fatto con PazientiWsBaseInsert2
							--
							EXEC PazientiNotificheAdd @Id, 6, @Identity --0=Msg; 1= UI; 2=WS; 3=Batch;4=Msg-notifica merge;5=UI-notifica merge; 6=ws-merge 
							--
							-- Se sono qui il merge è stato eseguito imposto il padre come Id da restituire
							-- perchè devo restituire il paziente attivo
							--
							SET @Id = @IdPazientePadre
						END

						PRINT 'Step 6) IdPaziente ROOT @Id: ' + ISNULL(CAST(@Id AS VARCHAR(40)), 'NULL')
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
    ON OBJECT::[dbo].[PazientiWsCercaOrAggiunge] TO [DataAccessWs]
    AS [dbo];

