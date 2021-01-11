






-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	
-- Modify date: 2018-08-02 - ETTORE: aggiunto il campo Attributi
-- Modify date: 2018-09-11 - ETTORE: aggiunto altri campi (per poter avre tutti i campi restituiti dal metodo di dettaglio WS2.PazientiDettaglio2ById
-- =============================================
CREATE VIEW [dbo].[PazientiMsgBaseResult]
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
	CodiceAslRes,
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
	CodiceAslAss,
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
	-- Modify date: 2018-09-11 - ETTORE: aggiunto altri campi
	Disattivato,
	dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice)  AS ProvinciaNascitaCodice,
	dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice)) AS ProvinciaNascitaNome	,
	dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice) AS ProvinciaResCodice,
	dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice)) AS ProvinciaResNome,
	dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslResCodice)  AS ProvinciaAslResCodice,
	dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslResCodice)) AS ProvinciaAslResNome,
	dbo.LookupIstatComuni(ComuneAslResCodice) AS ComuneAslResNome,
	dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneDomCodice) AS ProvinciaDomCodice,
	dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneDomCodice)) AS ProvinciaDomNome,
	dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslAssCodice) AS ProvinciaAslAssCodice,
	dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslAssCodice)) AS ProvinciaAslAssNome,
	dbo.LookupIstatComuni(ComuneAslAssCodice) AS ComuneAslAssNome,
	dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneRecapitoCodice) AS ProvinciaRecapitoCodice,
	dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneRecapitoCodice)) AS ProvinciaRecapitoNome,
	-- Modify date: 2018-08-02 - ETTORE: aggiunto il campo Attributi
	Attributi
FROM  
	Pazienti with(nolock)


