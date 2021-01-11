






-- =============================================
-- Author:		ETTORE
-- Create date: 2014-09-16 
-- Description:	Introdotta per utilizzare nuova logica di aggancio paziente (per prepararsi al demerge degli utenti) in sostituzione della PazientiOutputCercaFuzzyOrAggiunge.
--				La SP ricava tramite l'uso della funzione USER_NAME() l'utente chiamante e da questo deriva
--				la provenienza da usare in fase di inserimento
--				1) Se il paziente viene trovato per [Provenienza, IdProvenienza] restituisce quello trovato a prescindere dal suo stato attivo/fuso
--				2) Se il paziente viene trovato tramite confronto anagrafico [cognome, nome, ...] restituisce quello attivo
--				Normalizzazione dei codici istat dei comuni
--				Gestione dell'incoerenza istat dei comuni. Se codici istat dei comuni sono incoerenti genero una eccezione
--				Usata dalla Data Access del DWH.
-- Modify date: 2016-05-26: Rimosso controllo accesso di lettura
-- Modify date: 2016-10-27 - ETTORE: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
--		 							 Commentati i vari PRINT
-- Modify date: 2018-01-22 - ETTORE: Uso delle nuova function dbo.GetErroreIncoerenzaIstat() per la restituzione dell'errore ISTAT per evitare NESTED INSERT EXEC STATEMENT
-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputCercaAggancioPaziente]
(
	@ProvenienzaDiRicerca varchar(16)	
	, @IdProvenienzaDiRicerca varchar(64)
	, @IdProvenienzaDiInserimento varchar(64) --da usare in caso di inserimento della posizione
	, @Tessera varchar(16) = null
	, @Cognome varchar(64) = null
	, @Nome varchar(64) = null
	, @DataNascita datetime = null
	, @Sesso varchar(1) = null
	, @ComuneNascitaCodice varchar(6) = null
	, @NazionalitaCodice varchar(3) = null
	, @CodiceFiscale varchar(16) = null
	-- Dati di residenza
	, @ComuneResCodice varchar(6) = null
	, @SubComuneRes varchar(64) = null
	, @IndirizzoRes varchar(256) = null
	, @LocalitaRes varchar(128) = null 
	, @CapRes varchar(8) = null
	-- Dati di domicilio
	, @ComuneDomCodice varchar(6) = null
	, @SubComuneDom varchar(64) = null
	, @IndirizzoDom varchar(256) = null
	, @LocalitaDom varchar(128) = null
	, @CapDom varchar(8) = null
	-- Altri dati
	, @IndirizzoRecapito varchar(256) = null
	, @LocalitaRecapito varchar(128) = null
	, @Telefono1 varchar(20) = null
	, @Telefono2 varchar(20) = null
	, @Telefono3 varchar(20) = null
) AS
BEGIN

	DECLARE @ProvenienzaDiInserimento varchar(16)	
	DECLARE @Identity varchar(64)			--l'utente che esegue la chiamata alla SP
	DECLARE @IdPaziente uniqueidentifier	--il paziente trovato/creato
	DECLARE @Disattivato int				--0=Attivo, 1=Cancellato, 2=Fuso
	DECLARE @IdPadre uniqueidentifier
	--DECLARE @DateStart as datetime
	--DECLARE @DateEnd as datetime
	DECLARE @TrovaPosizionePadre BIT
	SET NOCOUNT ON;
	
	--
	-- Inizializzo 
	--
	SET @TrovaPosizionePadre = 1
	--SET @DateStart = GETDATE()
	
	BEGIN TRY
		--
		-- Leggo l'utente da cui derivare i diritti di scrittura e la provenienza in scrittura
		--
		SET @Identity = USER_NAME()
		--	
		-- Calcolo provenienza dall' utente/Identity
		--
		SET @ProvenienzaDiInserimento = dbo.LeggePazientiProvenienza(@Identity)
		IF @ProvenienzaDiInserimento IS NULL
		BEGIN
			RAISERROR('Errore di Provenienza non trovata durante PazientiOutputCercaAggancioPaziente!', 16, 1)
			RETURN
		END
		IF ISNULL(@IdProvenienzaDiInserimento,'') = ''
		BEGIN
			RAISERROR('Errore il parametro @IdProvenienzaDiInserimento non può essere nullo durante PazientiOutputCercaAggancioPaziente!', 16, 1)
			RETURN
		END
		--
		-- Aggiusto i dati
		--		
		IF NOT @DataNascita IS NULL
			SET @DataNascita = CAST(CONVERT(VARCHAR(10), @DataNascita, 120) AS DATETIME)
		IF @Tessera = ''
			SET @Tessera = NULL
		IF @CodiceFiscale = ''
			SET @CodiceFiscale = NULL
		--
		-- @Cognome = '' è permesso nel match nel DWH, quindi non lo metto a NULL
		-- @Nome = '' è permesso nel match nel DWH, quindi non lo metto a NULL
		--
			
		--
		-- Controllo @IdProvenienzaDiInserimento: se finisce con '_' allora è mal compilato, probabilmente contiene solo il nome anagrafica
		--
		IF RIGHT(@IdProvenienzaDiInserimento , 1) = '_' 
			SET @IdProvenienzaDiInserimento = CAST(NewId() AS VARCHAR(64))
			
		--
		-- 1) : Cerco il paziente per @ProvenienzaDiRicerca, @IdProvenienzaDiRicerca
		--
		IF @ProvenienzaDiRicerca <> 'SAC'
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE 
					Provenienza = @ProvenienzaDiRicerca 
					AND IdProvenienza = @IdProvenienzaDiRicerca
					AND Disattivato IN (0,2) --solo attivi o fusi
			ORDER BY
				Disattivato --0=attivo,1=cancellato,2=Fuso
		END
		ELSE
		BEGIN
			--
			-- Se @ProvenienzaDiRicerca = SAC allora @IdProvenienzaDiRicerca è il guid del record paziente
			-- Verifico che @IdProvenienzaDiRicerca sia un GUID
			--
			IF dbo.IsGUID(@IdProvenienzaDiRicerca) = 1
			BEGIN 
				SELECT 
					@IdPaziente = Id
					, @Disattivato = Disattivato
				FROM Pazienti
				WHERE 
					Id = @IdProvenienzaDiRicerca
					AND Disattivato IN (0,2) --solo attivi o fusi
			END
		END
		IF NOT @IdPaziente IS NULL 
		BEGIN
			--
			-- Ho trovato l'IdPaziente per [Provenienza, IdProvenienza] quindi non lo devo traslare nell'attivo/padre
			--
			SET @TrovaPosizionePadre = 0
			--PRINT '1) Trovato per provenienza, idprovenienza'
		END
		
		
		--
		-- 2) : Cerco per Cognome, Nome, CodiceSanitario, CodiceFiscale, DataNascita
		--
		IF (@IdPaziente IS NULL) 
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id
				, @Disattivato = Disattivato 
			FROM Pazienti
			WHERE Cognome = @Cognome 
				AND Nome = @Nome 
				AND Tessera = @Tessera 
				AND CodiceFiscale = @CodiceFiscale 
				AND DataNascita = @DataNascita
				AND Disattivato IN (0,2) --solo attivi o fusi
			ORDER BY LivelloAttendibilita desc, Disattivato
			--IF NOT @IdPaziente IS NULL PRINT '2) Trovato per Cognome, Nome, CodiceSanitario, CodiceFiscale, DataNascita'
		END
		
		--
		-- 3) : Cerco per Cognome, Nome, CodiceFiscale, DataNascita
		--
		IF (@IdPaziente IS NULL) 
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id
				, @Disattivato = Disattivato 
			FROM Pazienti
			WHERE Cognome = @Cognome 
				AND Nome = @Nome 
				AND CodiceFiscale = @CodiceFiscale 
				AND DataNascita = @DataNascita
				AND Disattivato IN (0,2) --solo attivi o fusi
			ORDER BY LivelloAttendibilita desc, Disattivato
			--IF NOT @IdPaziente IS NULL PRINT '3) Trovato per Cognome, Nome, CodiceFiscale, DataNascita'
		END		
		
		--
		-- 4) : Cerco per Cognome, Nome, CodiceFiscale
		-- 
		IF @IdPaziente IS NULL
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id 
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE 
				Cognome = @Cognome 
				AND Nome = @Nome 
				AND (CodiceFiscale = @CodiceFiscale AND @CodiceFiscale <> '0000000000000000')
				AND Disattivato IN (0,2) --solo attivi o fusi				
			ORDER BY LivelloAttendibilita desc , Disattivato
		
			--IF NOT @IdPaziente IS NULL PRINT '4) Trovato per Cognome, Nome, CodiceFiscale'	
		END
		--
		-- 5) : Cerco per Cognome, Nome, DataNascita
		-- 
		IF @IdPaziente IS NULL
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id 
				, @Disattivato = Disattivato	
			FROM Pazienti
			WHERE 
				Cognome = @Cognome 
				AND Nome = @Nome 
				AND DataNascita = @DataNascita
				AND Disattivato IN (0,2) --solo attivi o fusi				
			ORDER BY LivelloAttendibilita desc, Disattivato
			
			--IF NOT @IdPaziente IS NULL PRINT '5) Trovato per Cognome, Nome, DataNascita'
		END
		--
		-- 6) : Cerco per Cognome, Nome, Tessera Sanitaria
		-- 
		IF @IdPaziente IS NULL
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id 
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE 
				Cognome = @Cognome 
				AND Nome = @Nome 
				AND Tessera = @Tessera
				AND Disattivato IN (0,2) --solo attivi o fusi				
			ORDER BY LivelloAttendibilita desc , Disattivato
			
			--IF NOT @IdPaziente IS NULL PRINT '6) Trovato per Cognome, Nome, Tessera(CodiceSanitario)'
		END
		----------------------------------------------------------------------------------------------
		-- 7) : Ricerca ProvenienzaDiInserimento e IdProvenienzaDiInserimento
		--		MI EVITA DI FARE L'INSERIMENTO DI UNA POSIZIONE ESISTENTE
		----------------------------------------------------------------------------------------------
		IF @IdPaziente IS NULL
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id
				, @Disattivato = Disattivato 
			FROM Pazienti
			WHERE 
				Provenienza = @ProvenienzaDiInserimento 
				AND IdProvenienza = @IdProvenienzaDiInserimento
				AND Disattivato IN (0,2) --solo attivi o fusi				
			ORDER BY
				Disattivato --0=attivo
			--IF NOT @IdPaziente IS NULL PRINT '7) Trovato per @ProvenienzaDiInserimento, @IdProvenienzaDiInserimento'
		END		
		--
		-- 8) Se @IdPaziente IS NULL non ho trovato la posizione anagrafica,
		--    nemmeno quella che devo inserire, quindi procedo con l'inserimento
		--
		IF @IdPaziente IS NULL
		BEGIN 
				IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
				BEGIN
					EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiOutputCercaAggancioPaziente', 'Utente non ha i permessi di scrittura!'
					RAISERROR('Errore di controllo accessi durante PazientiOutputCercaAggancioPaziente!', 16, 1)
					RETURN
				END
				--
				-- Aggiusto il codice fiscale per l'inserimento
				--				
				IF ISNULL(@CodiceFiscale,'') = ''
					SET @CodiceFiscale = '0000000000000000'
				--
				-- Questa è la condizione della ExtPazienteAggiungi3(): deve rimanere tutto uguale a quelo che si faceva con
				-- join su DWH
				--
				IF (ISNULL(@Cognome,'') <> '' AND ISNULL(@Nome,'') <> '' AND ISNULL(@CodiceFiscale,'') <> '')
				BEGIN
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
					
					--Vecchio codice: richiamato dalle manteinance genera errore NESTED EXEC INSTER STATEMENT 
					--DECLARE @TableIstatErrorCode AS TABLE (ERROR_CODE INTEGER)
					--INSERT INTO @TableIstatErrorCode (ERROR_CODE )
					--EXECUTE IstatWsIncoerenzaIstatVerifica @Identity, @ComuneNascitaCodice, @ComuneResCodice, @ComuneDomCodice, @DataNascita
					--SELECT @IstatErrorCode = ERROR_CODE  FROM @TableIstatErrorCode 

					--MODIFICA ETTORE: 2018-01-22: uo nuova function per ottenere eventuale errore ISTAT
					SELECT @IstatErrorCode = dbo.GetErroreIncoerenzaIstat(@ComuneNascitaCodice, @ComuneResCodice, @ComuneDomCodice, @DataNascita)

					SELECT @IstatErrorMessage = dbo.LookUpIstatErrorCode(@IstatErrorCode)
					IF @IstatErrorCode > 0 
					BEGIN
						RAISERROR(@IstatErrorMessage , 16,1)
						RETURN
					END
					--
					-- Valorizzo l'id del record della nuova posizione anagrafica
					--
					SET @IdPaziente = newid()
					--
					-- Imposto la data sequenza al valore minimo
					--
					DECLARE @DataSequenza datetime								
					SET @DataSequenza = GETUTCDATE() --'1753-01-01'
				
					--PRINT 'Inserimento nuova posizione anagrafica'
					--
					-- Inserisco
					--
					EXEC dbo.PazientiWsBaseInsert2 @Identity, @DataSequenza, @IdPaziente, @IdProvenienzaDiInserimento, @Tessera, @Cognome, @Nome, @DataNascita, @Sesso, 
													@ComuneNascitaCodice, @NazionalitaCodice, @CodiceFiscale, @ComuneResCodice, 
													@SubComuneRes, @IndirizzoRes, @LocalitaRes, @CapRes, @ComuneDomCodice, @SubComuneDom, 
													@IndirizzoDom, @LocalitaDom, @CapDom, @IndirizzoRecapito, @LocalitaRecapito, 
													@Telefono1, @Telefono2, @Telefono3
				END
				ELSE
				BEGIN
					RAISERROR('Parametri di inserimento non validi. Non è possibile inserire una posizione anagrafica con Cognome=vuoto o Nome=vuoto o CodiceFiscale=vuoto.', 16, 1)
					RETURN
				END
		END
		ELSE
		BEGIN
			--
			-- Se sono qui ho trovato la posizione anagrafica
			-- A questo punto poichè le ricerche fuzzy non mi assicurano che l'@Id trovato sia quello di una posizione attiva
			-- devo assicurarmi di restituire la posizione attiva SE E SOLO SE il match non è avvenuto per [Provenienza, IdProvenienza]
			--
			If @Disattivato = 2 AND @TrovaPosizionePadre = 1
			BEGIN
				--PRINT '   La posizione trovata ' + CAST(@IdPaziente AS VARCHAR(40)) + ' è una posizione fusa (Disattivato=2) -> ricerco il padre'
				--
				-- Cerco il padre della posizione con Id=@IdPaziente
				--
				SET @IdPadre = NULL
				SELECT TOP 1 @IdPadre = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
				IF NOT @IdPadre IS NULL
				BEGIN
					--PRINT '   Trovato il padre della fusione: ' + CAST(@IdPadre AS VARCHAR(40))
					SET @IdPaziente = @IdPadre
				END
			END
		END
		--
		-- MODIFICA ETTORE 2016-10-27: A questo punto @IdPaziente è il paziente attivo se non è statao trovato per [Provenienza, IdProvenienza]
		--
		DECLARE @DataDecesso DATETIME 
		IF NOT @IdPaziente IS NULL
		BEGIN
			IF @Disattivato = 2 AND @TrovaPosizionePadre = 0
			BEGIN
				--In questo caso @idPaziente non è stato traslato nell'attivo : lo faccio ora per ricavare la DataDecesso
				DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
				SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
				SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
			END
			ELSE 
			BEGIN
				--In tutti questi casi l'IdPaziente è quello attivo
				SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)
			END
		END

		--
		-- Modify date: 2020-10-21: Ettore - Valorizzazione del campo DataUltimoUtilizzo
		--
		UPDATE dbo.Pazienti
			SET DataUltimoUtilizzo = GETDATE()
		WHERE Id = @IdPaziente


		--
		-- Eseguo la query per restituire i dati
		--
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
		
		--SET @DateEnd = GETDATE()
		--PRINT 'Durata esecuzione (ms): ' + CAST(DATEDIFF(ms, @DateStart, @dateEnd) AS VARCHAR(10))
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = 'PazientiOutputCercaAggancioPaziente' + 
			' ErrorNumber: ' + CONVERT(varchar(8), ERROR_NUMBER()) +
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
    ON OBJECT::[dbo].[PazientiOutputCercaAggancioPaziente] TO [DataAccessSql]
    AS [dbo];

