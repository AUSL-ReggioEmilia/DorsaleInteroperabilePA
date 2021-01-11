﻿

CREATE VIEW [dbo].[PazientiAttiviMsgBaseResult]
AS
SELECT 
	Id, 
	Provenienza, 
	IdProvenienza,
	DataInserimento, 
	DataModifica,
	DataSequenza, 
	LivelloAttendibilita, 
	Ts,
	Tessera, 
	Cognome, 
	Nome, 
	DataNascita, 
	Sesso, 
	ComuneNascitaCodice, 
	dbo.LookupIstatComuni(ComuneNascitaCodice) AS ComuneNascitaNome,
	NazionalitaCodice, 
	dbo.LookupIstatNazioni(NazionalitaCodice) AS NazionalitaNome,
	dbo.LookupIstatComuni(ComuneResCodice) AS ComuneResNome,
	CodiceFiscale,
	CONVERT(varchar, DatiAnamnestici) AS DatiAnamnestici,
	MantenimentoPediatra, 
	CapoFamiglia,	
	Indigenza, 
	CodiceTerminazione, 
	DescrizioneTerminazione,
	ComuneResCodice, 
	SubComuneRes, 
	IndirizzoRes, 
	LocalitaRes, 
	CapRes, 
	DataDecorrenzaRes, 
	ComuneAslResCodice, 
	CodiceAslRes, -- dbo.LookupIstatAslCodiceEsteso(CodiceAslRes, ComuneAslResCodice) AS CodiceAslRes, 
	dbo.LookupIstatAsl(CodiceAslRes, ComuneAslResCodice) AS AslResNome,
	RegioneResCodice,
	dbo.LookupIstatRegioni(RegioneResCodice) AS RegioneResNome ,
	ComuneDomCodice, 
	dbo.LookupIstatComuni(ComuneDomCodice) AS ComuneDomNome,
	SubComuneDom, 
	IndirizzoDom, 
	LocalitaDom, 
	CapDom, 
	PosizioneAss, 
	RegioneAssCodice, 
	dbo.LookupIstatRegioni(RegioneAssCodice) AS RegioneAssNome,
	ComuneAslAssCodice, 
	CodiceAslAss, --dbo.LookupIstatAslCodiceEsteso(CodiceAslAss, ComuneAslAssCodice) AS CodiceAslAss,
	dbo.LookupIstatAsl(CodiceAslAss, ComuneAslAssCodice) AS AslAssNome,
	DataInizioAss, 
	DataScadenzaAss, 
	DataTerminazioneAss, 
	DistrettoAmm, 
	DistrettoTer,
	Ambito, 
	CodiceMedicoDiBase, 
	CodiceFiscaleMedicoDiBase, 
	CognomeNomeMedicoDiBase,
	DistrettoMedicoDiBase, 
	DataSceltaMedicoDiBase, 
	ComuneRecapitoCodice, 
	dbo.LookupIstatComuni(ComuneRecapitoCodice) AS ComuneRecapitoNome,
	IndirizzoRecapito, 
	LocalitaRecapito,
	Telefono1, 
	Telefono2, 
	Telefono3,
	CodiceSTP, 
	DataInizioSTP, 
	DataFineSTP, 
	MotivoAnnulloSTP,
	--MODIFICA ETTORE 2018.07-30: aggiunto il campo Attributi
	Attributi
FROM  
	Pazienti with(nolock)

WHERE
		Disattivato = 0
	AND Occultato = 0
