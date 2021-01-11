
CREATE PROCEDURE [dbo].[PazientiUiAnonimizzazioniInserisci]
(
	@IdSacOriginale uniqueidentifier
	, @Utente VARCHAR(64)
	, @Note VARCHAR(2048) 
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY
		--
		-- Verifico se è attivo
		--
		DECLARE @Disattivato int
		SELECT @Disattivato = Disattivato 
		FROM Pazienti WHERE Id = @IdSacOriginale
		
		IF @Disattivato <> 0 
		BEGIN
			RAISERROR('L''anagrafica selezionata non è una anagrafica attiva.',16,1)
		END 
		
		--
		-- Inserisco il nuovo record
		--
		DECLARE @NewId UNIQUEIDENTIFIER
		SET @NewId = NEWID()
		--
		-- Calcolo l'Id di anonimizzazione: stringa nel formato ANXXYNNN
		--
		DECLARE @IdAnonimo VARCHAR(16)
		EXEC PazientiUiAnonimizzazioniGetIdAnonimo 	@IdAnonimo OUTPUT
		IF ISNULL(@IdAnonimo,'') = ''
		BEGIN 
			RAISERROR('Impossibile creare il codice di anonimizzazione.',16,1)			
		END 
		--
		-- Eseguo inserimento in tabella pazienti 
		--	
		INSERT INTO Pazienti
           (Id, DataInserimento, DataModifica, DataDisattivazione, DataSequenza
           , LivelloAttendibilita, Disattivato
           , Provenienza, IdProvenienza
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
           , Occultato           
           )
		SELECT 
			@NewId, GETDATE() AS DataInserimento, GETDATE() AS DataModifica, NULL AS DataDisattivazione, GETDATE() AS DataSequenza
			, dbo.ConfigPazientiLivelloAttendibilitaUi() AS LivelloAttendibilita, 0 AS Disattivato
			, dbo.ConfigPazientiProvenienzaUi() AS Provenienza, CAST(@NewId AS VARCHAR(40)) AS IdProvenienza
			, CAST(NULL AS VARCHAR(16)) AS Tessera
			, @IdAnonimo AS Cognome
			, @IdAnonimo AS Nome
			, CAST(CAST(YEAR(DataNascita) AS VARCHAR(4)) + '-01-01' AS DATETIME) AS DataNascita
			, Sesso			--Si lascia il Sesso della posizione originale
			, '000000' AS ComuneNascitaCodice
			, '000' AS NazionalitaCodice
			, '0000000000000000'AS CodiceFiscale
			, CAST(NULL AS VARBINARY(MAX)) AS DatiAnamnestici
			, CAST(NULL AS BIT) AS MantenimentoPediatra
			, CAST(NULL AS BIT) AS CapoFamiglia
			, CAST(NULL AS BIT) AS Indigenza
			, CAST(NULL AS VARCHAR(8)) AS CodiceTerminazione
			, CAST(NULL AS VARCHAR(64)) AS DescrizioneTerminazione
			, '000000' AS ComuneResCodice
			, CAST(NULL AS VARCHAR(64))AS SubComuneRes
			, CAST(NULL AS VARCHAR(256))AS IndirizzoRes
			, CAST(NULL AS VARCHAR(128))AS LocalitaRes
			, CAST(NULL AS VARCHAR(8))AS CapRes
			, CAST(NULL AS DATETIME) AS DataDecorrenzaRes
			, '000000' AS ComuneAslResCodice
			, '000' AS CodiceAslRes
			, '000' AS RegioneResCodice
			, '000000' AS ComuneDomCodice
			, CAST(NULL AS VARCHAR(64))AS SubComuneDom
			, CAST(NULL AS VARCHAR(256))AS IndirizzoDom
			, CAST(NULL AS VARCHAR(128))AS LocalitaDom
			, CAST(NULL AS VARCHAR(8)) AS CapDom
			, CAST(NULL AS TINYINT) AS PosizioneAss
			, '000' AS RegioneAssCodice
			, '000000' AS ComuneAslAssCodice
			, '000' AS CodiceAslAss
			, CAST(NULL AS DATETIME) AS DataInizioAss
			, CAST(NULL AS DATETIME) AS DataScadenzaAss
			, CAST(NULL AS DATETIME) AS DataTerminazioneAss
			, CAST(NULL AS VARCHAR(8)) AS DistrettoAmm
			, CAST(NULL AS VARCHAR(16)) AS DistrettoTer
			, CAST(NULL AS VARCHAR(16)) AS Ambito
			, CAST(NULL AS INT) AS CodiceMedicoDiBase
			, CAST(NULL AS VARCHAR(16)) AS CodiceFiscaleMedicoDiBase
			, CAST(NULL AS VARCHAR(128)) AS CognomeNomeMedicoDiBase
			, CAST(NULL AS VARCHAR(8)) AS DistrettoMedicoDiBase
			, CAST(NULL AS DATETIME) AS DataSceltaMedicoDiBase
			, '000000' AS ComuneRecapitoCodice
			, CAST(NULL AS VARCHAR(256)) AS IndirizzoRecapito
			, CAST(NULL AS VARCHAR(128)) AS LocalitaRecapito
			, CAST(NULL AS VARCHAR(20)) AS Telefono1
			, CAST(NULL AS VARCHAR(20)) AS Telefono2
			, CAST(NULL AS VARCHAR(20)) AS Telefono3
			, CAST(NULL AS VARCHAR(32)) AS CodiceSTP
			, CAST(NULL AS DATETIME) AS DataInizioSTP
			, CAST(NULL AS DATETIME) AS DataFineSTP
			, CAST(NULL AS VARCHAR(8)) AS MotivoAnnulloSTP
			,CAST(0 AS BIT) AS Occultato			
		FROM Pazienti WHERE Id = @IdSacOriginale
		--
		-- Eseguo inserimento in tabella Anonimizzazioni
		--
		INSERT INTO PazientiAnonimizzazioni(IdAnonimo, IdSacAnonimo, IdSacOriginale, Utente , Note)
		VALUES(@IdAnonimo, @NewId, @IdSacOriginale, @Utente, @Note)
		--
		-- Inserisce record di notifica
		--
		EXEC PazientiNotificheAdd @NewId, '1', @Utente
		
		--
		-- Rileggo il record inserito in PazientiAnonimizzazioni
		--
		SELECT IdAnonimo
			,IdSacAnonimo
			,IdSacOriginale
			,DataInserimento
			,Utente
			,Note
		FROM PazientiAnonimizzazioni
		WHERE IdAnonimo = @IdAnonimo
			
		COMMIT TRANSACTION;
	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
		  ROLLBACK TRANSACTION;
		END

		DECLARE @ErrorLogId INT
		EXECUTE LogError @ErrorLogId OUTPUT;
		EXECUTE RaiseErrorByIdLog @ErrorLogId 
		RETURN @ErrorLogId
	
	END CATCH
END	







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiAnonimizzazioniInserisci] TO [DataAccessUi]
    AS [dbo];

