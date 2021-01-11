
CREATE VIEW [dbo].[PazientiDropTable]
AS
SELECT  Operazione
	, Id
	, Tessera
	, Cognome
	, Nome
	, DataNascita
	, Sesso
	, ComuneNascitaCodice
	, NazionalitaCodice
	, CodiceFiscale
	, DatiAnagmestici
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
	, FusioneId
	, FusioneTessera
	, FusioneCognome
	, FusioneNome
	, FusioneDataNascita
	, FusioneSesso
	, FusioneComuneNascitaCodice
	, FusioneNazionalitaCodice
	, FusioneCodiceFiscale

FROM    dbo.PazientiQueue
WHERE	Utente = USER_NAME()
	--Provenienza = dbo.LeggePazientiProvenienza()






GO
GRANT INSERT
    ON OBJECT::[dbo].[PazientiDropTable] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiDropTable] TO [DataAccessSql]
    AS [dbo];

