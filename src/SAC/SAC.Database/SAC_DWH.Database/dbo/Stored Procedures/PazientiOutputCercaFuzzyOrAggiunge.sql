CREATE PROCEDURE [dbo].[PazientiOutputCercaFuzzyOrAggiunge]
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
	, @IdPazienteSac uniqueidentifier OUTPUT
) AS
 BEGIN 
	SET NOCOUNT ON
	--
	-- Mi collego al SAC sempre come SAC_DWC
	--
	DECLARE @LoginToSAC AS VARCHAR(40)
	SET @LoginToSAC = 'SAC_DWC'
	--
	-- Se codicefiscale è vuoto lo imposto a 0000000000000000 cosi da richiedere sempre
	-- la creazione di una nuova posizione nel SAC
	--
	IF ISNULL(@CodiceFiscale,'') = ''
		SET @CodiceFiscale = '0000000000000000'

	IF @DataNascita IS NULL
		SET @DataNascita = '1800-01-01'
		
	--------------------------------------------------------------
	-- Cambio utente per accesso al SAC
	--------------------------------------------------------------
	EXECUTE AS LOGIN = @LoginToSAC
	IF @@ERROR = 0
	BEGIN
		--------------------------------------------------------------
		-- Eseguo la SP del SAC
		--------------------------------------------------------------
		DECLARE @PazienteResult AS TABLE (Id uniqueidentifier, Provenienza varchar(16), IdProvenienza varchar(64)
           ,LivelloAttendibilita tinyint, DataInserimento datetime, DataModifica datetime, Tessera varchar(16)
           ,Cognome varchar(64), Nome varchar(64), DataNascita datetime, Sesso varchar(1), ComuneNascitaCodice varchar(6)
           ,ComuneNascitaNome varchar(128), ProvinciaNascitaCodice varchar(3), ProvinciaNascitaNome varchar(2)
           ,NazionalitaCodice varchar(3),NazionalitaNome varchar(128),CodiceFiscale varchar(16),DatiAnamnestici varchar(30)
           ,MantenimentoPediatra bit,CapoFamiglia bit,Indigenza bit,CodiceTerminazione varchar(8),DescrizioneTerminazione varchar(64)
           ,ComuneResCodice varchar(6),ComuneResNome varchar(128),ProvinciaResCodice varchar(3),ProvinciaResNome varchar(2)
           ,SubComuneRes varchar(64),IndirizzoRes varchar(256),LocalitaRes varchar(128),CapRes varchar(8),DataDecorrenzaRes datetime
           ,ProvinciaAslResCodice varchar(3),ProvinciaAslResNome varchar(2),ComuneAslResCodice varchar(6),ComuneAslResNome varchar(128)
           ,CodiceAslRes varchar(3),RegioneResCodice varchar(3),RegioneResNome varchar(128),ComuneDomCodice varchar(6)
           ,ComuneDomNome varchar(128),ProvinciaDomCodice varchar(3),ProvinciaDomNome varchar(2),SubComuneDom varchar(64)
           ,IndirizzoDom varchar(256),LocalitaDom varchar(128),CapDom varchar(8),PosizioneAss tinyint
           ,RegioneAssCodice varchar(3),RegioneAssNome varchar(128),ProvinciaAslAssCodice varchar(3),ProvinciaAslAssNome varchar(2)
           ,ComuneAslAssCodice varchar(6),ComuneAslAssNome varchar(128),CodiceAslAss varchar(3),DataInizioAss datetime
           ,DataScadenzaAss datetime,DataTerminazioneAss datetime,DistrettoAmm varchar(8),DistrettoTer varchar(16)
           ,Ambito varchar(16),CodiceMedicoDiBase int,CodiceFiscaleMedicoDiBase varchar(16),CognomeNomeMedicoDiBase varchar(128)
           ,DistrettoMedicoDiBase varchar(8),DataSceltaMedicoDiBase datetime,ComuneRecapitoCodice varchar(6)
           ,ComuneRecapitoNome varchar(128),ProvinciaRecapitoCodice varchar(3),ProvinciaRecapitoNome varchar(2),IndirizzoRecapito varchar(256)
           ,LocalitaRecapito varchar(128),Telefono1 varchar(20),Telefono2 varchar(20),Telefono3 varchar(20),CodiceSTP varchar(32)
           ,DataInizioSTP datetime,DataFineSTP datetime,MotivoAnnulloSTP varchar(8),StatusCodice tinyint,StatusNome varchar(10))
		
		BEGIN TRY
			--
			-- Eseguo la SP sul SAC
			--
			INSERT INTO @PazienteResult (Id , Provenienza , IdProvenienza 
			   ,LivelloAttendibilita , DataInserimento , DataModifica , Tessera 
			   ,Cognome , Nome , DataNascita , Sesso , ComuneNascitaCodice 
			   ,ComuneNascitaNome , ProvinciaNascitaCodice , ProvinciaNascitaNome 
			   ,NazionalitaCodice ,NazionalitaNome ,CodiceFiscale ,DatiAnamnestici 
			   ,MantenimentoPediatra ,CapoFamiglia ,Indigenza ,CodiceTerminazione ,DescrizioneTerminazione 
			   ,ComuneResCodice ,ComuneResNome ,ProvinciaResCodice ,ProvinciaResNome 
			   ,SubComuneRes ,IndirizzoRes ,LocalitaRes ,CapRes ,DataDecorrenzaRes 
			   ,ProvinciaAslResCodice ,ProvinciaAslResNome ,ComuneAslResCodice ,ComuneAslResNome 
			   ,CodiceAslRes ,RegioneResCodice ,RegioneResNome ,ComuneDomCodice 
			   ,ComuneDomNome ,ProvinciaDomCodice ,ProvinciaDomNome ,SubComuneDom 
			   ,IndirizzoDom ,LocalitaDom ,CapDom ,PosizioneAss 
			   ,RegioneAssCodice ,RegioneAssNome ,ProvinciaAslAssCodice ,ProvinciaAslAssNome 
			   ,ComuneAslAssCodice ,ComuneAslAssNome ,CodiceAslAss ,DataInizioAss 
			   ,DataScadenzaAss ,DataTerminazioneAss ,DistrettoAmm ,DistrettoTer 
			   ,Ambito ,CodiceMedicoDiBase ,CodiceFiscaleMedicoDiBase ,CognomeNomeMedicoDiBase 
			   ,DistrettoMedicoDiBase ,DataSceltaMedicoDiBase ,ComuneRecapitoCodice 
			   ,ComuneRecapitoNome ,ProvinciaRecapitoCodice ,ProvinciaRecapitoNome ,IndirizzoRecapito 
			   ,LocalitaRecapito ,Telefono1 ,Telefono2 ,Telefono3 ,CodiceSTP 
			   ,DataInizioSTP ,DataFineSTP ,MotivoAnnulloSTP ,StatusCodice ,StatusNome)
			 EXECUTE [dbo].[SAC_PazientiOutputCercaFuzzyOrAggiunge]
				@ProvenienzaDiRicerca,@IdProvenienzaDiRicerca,@IdProvenienzaDiInserimento
				,@Tessera,@Cognome,@Nome,@DataNascita,@Sesso
				,@ComuneNascitaCodice,@NazionalitaCodice,@CodiceFiscale
				-- GLi altri parametri li lascio con default=NULL
				--,@ComuneResCodice=NULL
				--,@SubComuneRes,@IndirizzoRes,@LocalitaRes,@CapRes
				--,@ComuneDomCodice,@SubComuneDom,@IndirizzoDom,@LocalitaDom,@CapDom
				--,@IndirizzoRecapito,@LocalitaRecapito,@Telefono1,@Telefono2,@Telefono3
		END TRY
		BEGIN CATCH
		END CATCH
			
		--
		-- Restituisco nel parametro di OUTPUT l'ID del paziente SAC
		--
		SELECT @IdPazienteSac = Id FROM @PazienteResult
		PRINT 'SACConnDwh: @IdPazienteSac:'  + CAST(@IdPazienteSac AS VARCHAR(40))
		
		--------------------------------------------------------------
		-- Ripristina all'utente iniziale
		--------------------------------------------------------------
		REVERT

		--------------------------------------------------------------
		-- Ritorno 1 se errore
		--------------------------------------------------------------
		IF @@ERROR <> 0
			RETURN 1
		ELSE
			RETURN 0
		
	END ELSE BEGIN
		--
		-- Ritorno errore di impesonificazione
		--
		DECLARE @ErrMsg AS VARCHAR(500)
		SET @ErrMsg = 'SACConnDwh: Errore durante impersonificazione utente ' + @LoginToSAC + ' durante PazientiOutputCercaFuzzyOrAggiunge!'
		RAISERROR(@ErrMsg, 16, 1)
		RETURN 1020
	END 
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputCercaFuzzyOrAggiunge] TO [ExecuteDwh]
    AS [dbo];

