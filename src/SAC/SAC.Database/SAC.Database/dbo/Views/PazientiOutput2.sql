




CREATE VIEW [dbo].[PazientiOutput2]
AS
--
--2016-05-26 SANDRO Rimosso WHERE LeggePazientiPermessiLettura()=1
--MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione sia per attivi che fusi
--MODIFICA ETTORE 2017-05-22: Utilizzo della nuova funzione "LookUpDizionarioIstatAsl" per ricavare la descrizione dell'ASL sia per asl di residenza che ASL dell'assistito
--							Se non riesce a fare lookup la funzione retgituisce la concatenazione di CodiceRegione + CodiceAsl.
--							Prima si utilizzava la funzione "LookUpIstatAsl" che non era corretta in quanto restituiva una descrizione del comune e non dell'asl
--
SELECT Id 
		, Provenienza
		, IdProvenienza
		, DataInserimento
		, DataModifica
		, Occultato
		, Disattivato

		, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, ComuneNascitaCodice
		, dbo.LookupIstatComuni(ComuneNascitaCodice) AS ComuneNascitaNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice) AS ProvinciaNascitaCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice)) AS ProvinciaNascitaNome
		, NazionalitaCodice
		, dbo.LookupIstatNazioni(NazionalitaCodice) AS NazionalitaNome
		, CodiceFiscale

		, CONVERT(VARCHAR(MAX), NULL) AS DatiAnamnestici
		, ISNULL(MantenimentoPediatra, 0) AS MantenimentoPediatra
		, ISNULL(CapoFamiglia, 0) AS CapoFamiglia
		, ISNULL(Indigenza, 0) AS Indigenza
		
		--, CodiceTerminazione
		, CASE WHEN Disattivato=0 AND NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN
			CAST('4' AS VARCHAR(8))
		WHEN Disattivato=2 AND NOT dbo.GetPazientiDataDecesso(FusioneId) IS NULL THEN
	  		CAST('4' AS VARCHAR(8))
		ELSE
			CodiceTerminazione
		END AS CodiceTerminazione

		--, DescrizioneTerminazione
		, CASE WHEN Disattivato=0 AND NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN
			CAST('DECESSO' AS VARCHAR(64))
		WHEN Disattivato=2 AND NOT dbo.GetPazientiDataDecesso(FusioneId) IS NULL THEN
	  		CAST('DECESSO' AS VARCHAR(64))
		ELSE
			DescrizioneTerminazione
		END AS DescrizioneTerminazione

		, ComuneResCodice
		, dbo.LookupIstatComuni(ComuneResCodice) AS ComuneResNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice) AS ProvinciaResCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice)) AS ProvinciaResNome
		, SubComuneRes
		, IndirizzoRes
		, LocalitaRes
		, CapRes
		, DataDecorrenzaRes
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslResCodice) AS ProvinciaAslResCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslResCodice)) AS ProvinciaAslResNome
		, ComuneAslResCodice
		, dbo.LookUpDizionarioIstatAsl(RegioneResCodice, CodiceAslRes) AS AslResNome --Modifica Ettore 2017-05-22
		, CodiceAslRes --Modifica Ettore 28-12-2009 COALESCE(dbo.LookupIstatAslCodiceEsteso(CodiceAslRes, ComuneAslResCodice), (RegioneResCodice+'0'+CodiceAslRes)) AS CodiceAslRes
		, RegioneResCodice
		, dbo.LookupIstatRegioni(RegioneResCodice) AS RegioneResNome

		, ComuneDomCodice
		, dbo.LookupIstatComuni(ComuneDomCodice) AS ComuneDomNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneDomCodice) AS ProvinciaDomCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneDomCodice)) AS ProvinciaDomNome
		, SubComuneDom
		, IndirizzoDom
		, LocalitaDom
		, CapDom

		, PosizioneAss
		, RegioneAssCodice
		, dbo.LookupIstatRegioni(RegioneAssCodice) AS RegioneAssNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslAssCodice) AS ProvinciaAslAssCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslAssCodice)) AS ProvinciaAslAssNome
		, ComuneAslAssCodice
		, dbo.LookUpDizionarioIstatAsl(RegioneAssCodice, CodiceAslAss) AS AslAssNome --Modifica Ettore 2017-05-22
		, CodiceAslAss --Modifia Ettore 28-12-2009 COALESCE(dbo.LookupIstatAslCodiceEsteso(CodiceAslAss, ComuneAslAssCodice), (RegioneAssCodice+'0'+CodiceAslAss)) AS CodiceAslAss
		, DataInizioAss
		, DataScadenzaAss
		
		--, DataTerminazioneAss
		, CASE WHEN Disattivato=0 AND NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN
			dbo.GetPazientiDataDecesso(Id)
		WHEN Disattivato=2 AND NOT dbo.GetPazientiDataDecesso(FusioneId) IS NULL THEN
	  		dbo.GetPazientiDataDecesso(FusioneId)
		ELSE
			DataTerminazioneAss
		END AS DataTerminazioneAss

		, DistrettoAmm
		, DistrettoTer
		, Ambito

		, CodiceMedicoDiBase
		, CodiceFiscaleMedicoDiBase
		, CognomeNomeMedicoDiBase
		, DistrettoMedicoDiBase
		, DataSceltaMedicoDiBase

		, ComuneRecapitoCodice
		, dbo.LookupIstatComuni(ComuneRecapitoCodice) AS ComuneRecapitoNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneRecapitoCodice) AS ProvinciaRecapitoCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneRecapitoCodice)) AS ProvinciaRecapitoNome
		, IndirizzoRecapito
		, LocalitaRecapito
		, Telefono1
		, Telefono2
		, Telefono3
		
		, CodiceSTP
		, DataInizioSTP
		, DataFineSTP
		, MotivoAnnulloSTP		

		, PDR.FusioneId
		, PDR.FusioneProvenienza
		, PDR.FusioneIdProvenienza

FROM
	Pazienti AS P WITH(NOLOCK) LEFT OUTER JOIN  PazientiDatiRoot AS PDR
		ON P.Id = PDR.IdPazienteFuso


GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiOutput2] TO [DataAccessSql]
    AS [dbo];

