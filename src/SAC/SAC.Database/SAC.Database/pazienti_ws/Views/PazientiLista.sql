




-- =============================================
-- Author:		Stefano P.
-- Create date: 25/10/2016
-- Modify date: 13/12/2016
-- Description:	Vista per le liste Pazienti
-- ModifyDate: 2018-05-08, simoneB: restituiti anche i campi ComuneResidenzaCodice e ComuneResidenzaNome
-- Modify Date: 2020-02-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
-- =============================================
CREATE VIEW [pazienti_ws].[PazientiLista]
AS

SELECT 
	  P.Id
	, P.Provenienza
	, P.IdProvenienza
	, P.LivelloAttendibilita
	, P.DataInserimento
	, P.DataModifica

	, P.Tessera
	, P.Cognome
	, P.Nome
	, P.DataNascita
	, P.Sesso
	, P.ComuneNascitaCodice
	, dbo.LookupIstatComuni(P.ComuneNascitaCodice) AS ComuneNascitaNome
	, P.NazionalitaCodice
	, dbo.LookupIstatNazioni(P.NazionalitaCodice) AS NazionalitaNome
	, P.CodiceFiscale		
	, [dbo].[GetPazientiDataDecesso](P.Id) As DataDecesso

	, P.CodiceMedicoDiBase as MedicoDiBaseCodice
	, P.CodiceFiscaleMedicoDiBase as MedicoDiBaseCodiceFiscale
	, P.CognomeNomeMedicoDiBase as MedicoDiBaseCognomeNome
	, P.DistrettoMedicoDiBase as MedicoDiBaseDistretto
	, P.DataSceltaMedicoDiBase as MedicoDiBaseDataScelta

	, CA.ConsensoAziendaleCodice
	, CA.ConsensoAziendaleDescrizione
	, CA.ConsensoAziendaleData
	, CS.ConsensoSoleCodice
	, CS.ConsensoSoleDescrizione
	, CS.ConsensoSoleData
	--Nuovi campi per filtrare anche su comune residenza
	, P.ComuneResCodice AS ComuneResidenzaCodice
	, IC.Nome AS ComuneResidenzaNome
	-- Modify Date: 2020-01-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
	, P.IndirizzoRes AS IndirizzoResidenza
	, P.LocalitaRes AS LocalitaResidenza
	, P.CapRes AS ComuneResidenzaCap
	---------------------------------------------------------------
	, P.PosizioneAss AS PosizioneAssistito
	, P.CodiceTerminazione AS TerminazioneCodice
	, P.DescrizioneTerminazione AS TerminazioneDescrizione
	, P.DataTerminazioneAss AS TerminazioneData
	--Dati di domicilio
	, P.ComuneDomCodice AS ComuneDomicilioCodice
	, ICD.Nome AS ComuneDomicilioNome
	, P.IndirizzoDom AS IndirizzoDomicilio
	, P.LocalitaDom AS LocalitaDomicilio
	, P.CapDom AS ComuneDomicilioCap


FROM
	dbo.Pazienti P with(nolock)
	LEFT OUTER JOIN dbo.IstatComuni AS IC --per la residenza
		ON P.ComuneResCodice = IC.Codice
	-- Modify Date: 2020-01-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
	LEFT OUTER JOIN dbo.IstatComuni AS ICD --per il domicilio
		ON P.ComuneDomCodice = ICD.Codice

OUTER APPLY 
	dbo.OttieneConsensiAziendalePerIdPaziente(P.Id) AS CA
OUTER APPLY 
	dbo.OttieneConsensiSolePerIdPaziente(P.Id) AS CS
WHERE
		P.Disattivato = 0
	AND P.Occultato = 0