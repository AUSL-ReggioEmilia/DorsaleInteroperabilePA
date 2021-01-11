
CREATE VIEW [dbo].[PazientiUiBaseResult]
AS
SELECT  Id
		, Provenienza
		, IdProvenienza
		, DataInserimento
		, DataModifica
		, DataDisattivazione
		, DataSequenza
		, LivelloAttendibilita
		, Disattivato
		, dbo.GetStatoDisattivatoPaziente(Disattivato) AS DisattivatoDescrizione
		, Occultato
		, Ts

		, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, ComuneNascitaCodice
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice) AS ProvinciaNascitaCodice
		, NazionalitaCodice
		, CodiceFiscale
		, CONVERT(VARCHAR, DatiAnamnestici) AS DatiAnamnestici
		, ISNULL(MantenimentoPediatra, 0) AS MantenimentoPediatra
		, ISNULL(CapoFamiglia, 0) AS CapoFamiglia
		, ISNULL(Indigenza, 0) AS Indigenza
		, CodiceTerminazione
		, DescrizioneTerminazione

		, ComuneResCodice
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice) AS ProvinciaResCodice
		, SubComuneRes
		, IndirizzoRes
		, LocalitaRes
		, CapRes
		, DataDecorrenzaRes
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslResCodice) AS ProvinciaAslResCodice
		, ComuneAslResCodice
		, CodiceAslRes
		, RegioneResCodice --tale campo si riferisce alla regione di riferimento asl
		, dbo.LookupAslRegioni(RegioneResCodice) AS RegioneAslResNome

		, ComuneDomCodice
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneDomCodice) AS ProvinciaDomCodice
		, SubComuneDom
		, IndirizzoDom
		, LocalitaDom
		, CapDom

		, PosizioneAss
		, RegioneAssCodice --tale campo si riferisce alla regione di riferimento asl
		, dbo.LookupAslRegioni(RegioneAssCodice) AS RegioneAslAssNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslAssCodice) AS ProvinciaAslAssCodice
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
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneRecapitoCodice) AS ProvinciaRecapitoCodice
		, IndirizzoRecapito
		, LocalitaRecapito
		, Telefono1
		, Telefono2
		, Telefono3
		, CodiceSTP

		, DataInizioSTP
		, DataFineSTP
		, MotivoAnnulloSTP		

FROM
	Pazienti with(nolock)

