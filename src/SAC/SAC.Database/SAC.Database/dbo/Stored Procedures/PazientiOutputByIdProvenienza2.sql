




-- =============================================
-- Author:		...
-- Create date: ...
-- Modify date: 2014-07-04: Ettore - Non uso più la SP PazientiWsDettaglioByIdProvenienza()
-- Modify date: 2016-05-26 Sandro -Rimosso controllo accesso di lettura
-- Modify date: 2016-10-27: Sovrascrivo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss se è valorizzata dataDecesso calcolata sulla catena, anche se l'anagrafica è fusa
-- Modify date: 2018-11-30: ETTORE - Caso Provenienza <> SAC: 1) Spezzata la prima query per trovare @IdPaziente e @Disattivato in due query separate per problemi di performance
--													 2) Eseguito select del record per @IdPaziente
-- Description:	Ritorna la lista dei pazienti
--				Ho copiato lo stesso codice che era prsente nella SP PazientiWsDettaglioByIdProvenienza
--				Ho bloccato l'output eliminando i SELECT * FROM PazientiDettaglioResult
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputByIdProvenienza2]
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)

AS
BEGIN
	SET NOCOUNT ON;

	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Il parametro Provenienza non può essere NULL!', 16, 1)
		RETURN
	END

	IF @IdProvenienza IS NULL
	BEGIN
		RAISERROR('Il parametro IdProvenienza non può essere NULL!', 16, 1)
		RETURN
	END
	
	DECLARE @DataDecesso AS DATETIME
	DECLARE @IdPaziente AS UNIQUEIDENTIFIER
	DECLARE @Disattivato AS TINYINT


	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	IF @Provenienza <> 'SAC'
	BEGIN
		--Ricavo l'idpaziente associato alla [provenienza, idProvenienza] per capire se è attivo, fuso, cancellato
		--Modify date: 2018-11-30: ETTORE --spezzato in due la query
		SELECT TOP 1 
			@IdPaziente = Id
			, @Disattivato = Disattivato
		FROM Pazienti
		WHERE
			(Provenienza = @Provenienza	AND IdProvenienza = @IdProvenienza)

		--Se l'IdPaziente è NULLO Provo a cercarlo nei sinonimi
		IF @IdPaziente IS NULL
		BEGIN
			SELECT TOP 1 
				@IdPaziente = Id
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE
				Pazienti.Id IN (
					SELECT PazientiSinonimi.IdPaziente
					FROM         
						PazientiSinonimi
					WHERE
						PazientiSinonimi.Provenienza = @Provenienza
						AND PazientiSinonimi.IdProvenienza = @IdProvenienza
						)
		END

		--
		-- Verifico se l'anagrafica identificata da @IdPaziente è Attiva o Fusa. Se Fusa devo calcolare il padre della fusione per trovare la data di decesso sulla catena
		--
		IF (NOT @IdPaziente IS NULL) 
		BEGIN 
			IF @Disattivato = 2
			BEGIN
				SELECT TOP 1 @IdPaziente = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
				SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)
			END 
			ELSE 
			IF @Disattivato = 0
			BEGIN
				SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)
			END 
			--Se l'anagrafica è CANCELLATA @DataDecesso rimane NULL
		END
		

		SELECT TOP 1 
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
		WHERE Id = @Idpaziente	--Modify date: 2018-11-30: ETTORE --eseguito query per @IdPaziente

	END
	ELSE
	BEGIN
		--
		-- Se @Provenienza = SAC allora @IdProvenienza è il guid del record paziente
		-- Verifico che @IdProvenienza sia un GUID
		--
		IF dbo.IsGUID(@IdProvenienza) = 1
		BEGIN 
			SELECT 
				@IdPaziente = Id
				, @Disattivato = Disattivato
			FROM Pazienti
			WHERE 
				Id = @IdProvenienza
		END
		--
		-- Se fuso cerco l'Id del padre
		--
		IF @Disattivato = 2 
		BEGIN
			--
			-- Cerco il padre della fusione
			--
			SELECT TOP 1 @IdPaziente = IdPaziente 
			FROM PazientiFusioni 
			WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
		END
		--
		-- Cerco la data di decesso
		--
		SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)

		--
		-- Restituisco il record del paziente: è unico poichè lo cerco per Id
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
		WHERE Id = @Idpaziente
	END	

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputByIdProvenienza2] TO [ExecuteBiztalk]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputByIdProvenienza2] TO [DataAccessSql]
    AS [dbo];

