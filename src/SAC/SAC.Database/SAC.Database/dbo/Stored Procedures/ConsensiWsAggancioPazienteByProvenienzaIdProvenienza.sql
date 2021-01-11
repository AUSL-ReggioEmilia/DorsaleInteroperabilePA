
CREATE PROCEDURE [dbo].[ConsensiWsAggancioPazienteByProvenienzaIdProvenienza]
(
	@Identity VARCHAR(64)
	, @ProvenienzaPaziente varchar(16)	
	, @IdProvenienzaPaziente varchar(64)
) AS
BEGIN
/*
	CREATA DA ETTORE 2014-10-29: 
		La SP è stata creata per separare la parte di aggancio paziente dalle ricerche sui pazienti, cosi da implementare le stesse regole 
		utilizzate per l'aggancio referti.
		Viene restituito l'IdPaziente a prescindere dal suo stato di Attivo/Fuso
		MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
									sia per attivi che fusi

		MODIFICA ETTORE 2018-06-05: Aggiunto la ricerca del paziente anche per provenienza SAC

*/
	DECLARE @IdPaziente uniqueidentifier
	DECLARE @Disattivato tinyint
	SET NOCOUNT ON;
	BEGIN TRY
		--	
		-- Controllo accesso
		--
		IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
		BEGIN
			EXEC PazientiEventiAccessoNegato @Identity, 0, 'ConsensiWsAggancioPazienteByProvenienzaIdProvenienza', 'Utente non ha i permessi di lettura!'
			RAISERROR('Errore di controllo accessi durante ConsensiWsAggancioPazienteByProvenienzaIdProvenienza!', 16, 1)
			RETURN
		END		
		--
		-- Cerco il paziente per @ProvenienzaPaziente, @IdProvenienzaPaziente
		--
		IF @ProvenienzaPaziente = 'SAC'
		BEGIN
			SELECT
				@IdPaziente = Id
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE 
				Id = CAST(@IdProvenienzaPaziente AS UNIQUEIDENTIFIER)
				AND Disattivato IN (0,2) --solo attivi o fusi
		END
		ELSE
		BEGIN 
			SELECT TOP 1 
				@IdPaziente = Id
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE 
					Provenienza = @ProvenienzaPaziente 
					AND IdProvenienza = @IdProvenienzaPaziente
					AND Disattivato IN (0,2) --solo attivi o fusi
			ORDER BY
				Disattivato
		END

		--
		-- Verifico se l'anagrafica identificata da @IdPaziente è Attiva o Fusa. Se Fusa devo calcolare il padre della fusione per trovare la data di decesso sulla catena
		--
		DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER	
		DECLARE @Datadecesso AS DATETIME
		IF (NOT @IdPaziente IS NULL) 
		BEGIN 
			IF @Disattivato = 2
			BEGIN
				SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
				SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
			END 
			ELSE
			BEGIN
				SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)
			END 
		END 
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
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = 'ConsensiWsAggancioPazienteByProvenienzaIdProvenienza' + 
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
    ON OBJECT::[dbo].[ConsensiWsAggancioPazienteByProvenienzaIdProvenienza] TO [DataAccessWs]
    AS [dbo];

