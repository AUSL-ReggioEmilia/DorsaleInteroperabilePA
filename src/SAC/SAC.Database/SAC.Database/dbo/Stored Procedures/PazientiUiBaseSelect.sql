
CREATE PROCEDURE [dbo].[PazientiUiBaseSelect]
(
	@Id AS uniqueidentifier
)
AS
BEGIN
/*
	MODIFICA ETTORE 2014-03-26:
		1) Tolto * e messo tutti i campi della vista

*/
	SET NOCOUNT ON;

	SELECT
		P.Id
		, P.Provenienza
		, P.IdProvenienza
		, P.DataInserimento
		, P.DataModifica
		, P.DataDisattivazione
		, P.DataSequenza
		, P.LivelloAttendibilita
		, P.Disattivato
		, P.DisattivatoDescrizione
		, P.Occultato
		, P.Ts
		, P.Tessera
		, P.Cognome
		, P.Nome
		, P.DataNascita
		, P.Sesso
		, P.ComuneNascitaCodice
		, P.ProvinciaNascitaCodice
		, P.NazionalitaCodice
		, P.CodiceFiscale
		, P.DatiAnamnestici
		, P.MantenimentoPediatra
		, P.CapoFamiglia
		, P.Indigenza
		, P.ComuneResCodice
		, P.ProvinciaResCodice
		, P.SubComuneRes
		, P.IndirizzoRes
		, P.LocalitaRes
		, P.CapRes
		, P.DataDecorrenzaRes
		, P.ProvinciaAslResCodice
		, P.ComuneAslResCodice
		, P.CodiceAslRes
		, P.RegioneResCodice
		, P.RegioneAslResNome
		, P.ComuneDomCodice
		, P.ProvinciaDomCodice
		, P.SubComuneDom
		, P.IndirizzoDom
		, P.LocalitaDom
		, P.CapDom
		, P.PosizioneAss
		, P.RegioneAssCodice
		, P.RegioneAslAssNome
		, P.ProvinciaAslAssCodice
		, P.ComuneAslAssCodice
		, P.CodiceAslAss
		, P.DataInizioAss
		, P.DataScadenzaAss
		, P.DistrettoAmm
		, P.DistrettoTer
		, P.Ambito
		, P.CodiceMedicoDiBase
		, P.CodiceFiscaleMedicoDiBase
		, P.CognomeNomeMedicoDiBase
		, P.DistrettoMedicoDiBase
		, P.DataSceltaMedicoDiBase
		, P.ComuneRecapitoCodice
		, P.ProvinciaRecapitoCodice
		, P.IndirizzoRecapito
		, P.LocalitaRecapito
		, P.Telefono1
		, P.Telefono2
		, P.Telefono3
		, P.CodiceSTP
		, P.DataInizioSTP
		, P.DataFineSTP
		, P.MotivoAnnulloSTP
		--
		-- Per determinare la data di decesso in riga
		-- Trasformo i NULL in '' per la gestione con combo
		--
		, ISNULL(P.CodiceTerminazione, '') AS CodiceTerminazione
		, ISNULL(P.DescrizioneTerminazione, '') AS DescrizioneTerminazione
		, P.DataTerminazioneAss		
		--
		-- Determinazione della data di decesso "aggregata"
		--
		, dbo.GetPazientiDataDecesso(ISNULL(PF.IdPaziente, P.Id)) AS DataDecesso
	FROM 
		PazientiUiBaseResult AS P WITH(NOLOCK)
		LEFT OUTER JOIN PazientiFusioni AS PF WITH(NOLOCK)
			ON P.Id = PF.IdPazienteFuso AND Abilitato= 1
	WHERE 
		P.Id = @Id
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiBaseSelect] TO [DataAccessUi]
    AS [dbo];

