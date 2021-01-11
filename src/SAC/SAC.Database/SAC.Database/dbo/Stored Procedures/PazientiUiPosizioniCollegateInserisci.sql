
-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2018-02-22
-- Description:	Inserisce nella tabella Pazienti la nuova anagrafica collegata
--				e inserisce nella tabella di relazione Pazienti-PosizioniCollegate
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiPosizioniCollegateInserisci]
(
	@IdSacOriginale uniqueidentifier
	, @Utente VARCHAR(64)
	, @Note VARCHAR(2048) 
	, @SessoPosizioneCollegata VARCHAR(1) 
	, @DataNascitaPosizioneCollegata DATETIME
	, @ComuneNascitaPosizioneCollegata VARCHAR(6)
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
		-- Calcolo l'Id della posizione collegata : stringa nel formato PCYY00000
		--
		DECLARE @IdPosizioneCollegata VARCHAR(16)
		EXEC dbo.PazientiUiPosizioniCollegateGetIdPosizioneCollegata 	@IdPosizioneCollegata OUTPUT
		IF ISNULL(@IdPosizioneCollegata,'') = ''
		BEGIN 
			RAISERROR('Impossibile creare il codice della posizione collegata.',16,1)			
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
			, Tessera
			, @IdPosizioneCollegata AS Cognome
			, @IdPosizioneCollegata AS Nome
			------------------------------------------------------------------------
			-- Valori impostabili da interfaccia
			------------------------------------------------------------------------
			, @DataNascitaPosizioneCollegata AS DataNascita
			, @SessoPosizioneCollegata AS Sesso		
			, @ComuneNascitaPosizioneCollegata AS ComuneNascitaCodice
			------------------------------------------------------------------------
			, NazionalitaCodice
			, '0000000000000000'AS CodiceFiscale
			, CAST(NULL AS VARBINARY(MAX)) AS DatiAnamnestici
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
		FROM Pazienti 
		WHERE Id = @IdSacOriginale

		--
		-- Eseguo inserimento in tabella PazientiPosizioniCollegate
		--
		INSERT INTO PazientiPosizioniCollegate([IdPosizioneCollegata],[IdSacPosizioneCollegata],[IdSacOriginale],[Utente],[Note])
		VALUES(@IdPosizioneCollegata, @NewId, @IdSacOriginale, @Utente, @Note)
		--
		-- Inserisce record di notifica
		--
		EXEC PazientiNotificheAdd @NewId, '1', @Utente
		
		--
		-- Rileggo il record inserito in PazientiPosizioniCollegate
		--
		SELECT 
			[IdPosizioneCollegata]
			,[IdSacPosizioneCollegata]
			,[IdSacOriginale]
			,[DataInserimento]
			,[Utente]
			,[Note]
		FROM [dbo].[PazientiPosizioniCollegate]
		WHERE IdPosizioneCollegata = @IdPosizioneCollegata
			
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
    ON OBJECT::[dbo].[PazientiUiPosizioniCollegateInserisci] TO [DataAccessUi]
    AS [dbo];

