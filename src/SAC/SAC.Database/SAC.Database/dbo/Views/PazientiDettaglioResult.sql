


CREATE VIEW [dbo].[PazientiDettaglioResult]
AS
SELECT 
	  Id
	, Provenienza
	, IdProvenienza
	, LivelloAttendibilita
	, DataInserimento
	, DataModifica

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
	, CONVERT(varchar, DatiAnamnestici) AS DatiAnamnestici
	, ISNULL(MantenimentoPediatra, 0) AS MantenimentoPediatra
	, ISNULL(CapoFamiglia, 0) AS CapoFamiglia
	, ISNULL(Indigenza, 0) AS Indigenza
	, CodiceTerminazione
	, DescrizioneTerminazione

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
	, dbo.LookupIstatComuni(ComuneAslResCodice) AS ComuneAslResNome
	, CodiceAslRes --dbo.LookupIstatAslCodiceEsteso(CodiceAslRes, ComuneAslResCodice) AS CodiceAslRes
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
	, dbo.LookupIstatComuni(ComuneAslAssCodice) AS ComuneAslAssNome
	, CodiceAslAss --dbo.LookupIstatAslCodiceEsteso(CodiceAslAss, ComuneAslAssCodice) AS CodiceAslAss
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

	, Disattivato AS StatusCodice
	, 'StatusNome' = 
		CASE			
			WHEN Disattivato = 0 THEN 'Attivo'
			WHEN Disattivato = 1 THEN 'Cancellato'
			WHEN Disattivato = 2 THEN 'Fuso'
		END
FROM
	Pazienti with(nolock)

WHERE
	Occultato = 0



