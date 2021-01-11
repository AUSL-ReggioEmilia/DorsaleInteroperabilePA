




CREATE VIEW [dbo].[PazientiUiBaseGestioneResult]
AS
/*
	MODIFICA ETTORE: 2014-03-27: Aggiunto i campi CodiceTerminazione e DataTerminazioneAss per determinare la data di decesso
	MODIFICA ETTORE: 2016-12-12: Se Sesso è NULL restituisco ''
*/
SELECT  Id
	  , DataModifica
	  , DataDisattivazione
	  , LivelloAttendibilita
	  , Disattivato
	  , dbo.GetStatoDisattivatoPaziente(Disattivato) AS DisattivatoDescrizione
	  , Provenienza
	  , IdProvenienza
	  , Occultato
	  , Cognome
	  , Nome
	  , DataNascita
	  , dbo.LookupIstatComuni(ComuneNascitaCodice) AS ComuneNascitaNome
	  , dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice)) AS ProvinciaNascitaNome
	  , ISNULL(Sesso,'') AS Sesso
	  , CodiceFiscale
	  , Tessera
	  , dbo.LookupIstatComuni(ComuneResCodice) AS ComuneResDescrizione
	  , dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice)) AS ProvinciaResDescrizione
	  , dbo.LookupIstatRegioni(RegioneResCodice) AS RegioneResDescrizione
	  --
	  -- Per determinare la data di decesso sul record
	  -- Se CodiceTerminazione='4' allora DataTerminazioneAss=Data di decesso
	  , CodiceTerminazione
	  ,	DataTerminazioneAss
FROM
	Pazienti with(nolock)
	

