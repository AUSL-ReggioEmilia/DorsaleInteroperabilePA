

CREATE PROCEDURE [dbo].[PazientiUiLista1]
(
	@Cognome varchar(64) = NULL,
	@Nome varchar(64) = NULL,
	@AnnoNascita as int = NULL,
	@CodiceFiscale as varchar(16) = NULL
)
WITH RECOMPILE --Ricalcola sempre il piano di esecuzione
AS
BEGIN
/*
	MODIFICA ETTORE: 2014-03-26
		1)	Gestione della data di decesso

*/
	SET NOCOUNT ON;

	SELECT 
		P.Id
		, P.Provenienza
		, (dbo.GetAggregazioneSistemiProvenienza(P.Id, '<br />')) as ProvenienzaFuse
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
		, P.CodiceTerminazione
		, P.DescrizioneTerminazione
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
		, P.DataTerminazioneAss
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
		,dbo.GetPazientiDataDecesso(ISNULL(PF.IdPaziente, P.ID)) AS DataDecesso
	FROM 
		dbo.PazientiUiBaseResult  AS P WITH(NOLOCK)
		LEFT OUTER JOIN PazientiFusioni AS PF with(nolock)
			ON P.ID = PF.IdPAzienteFuso AND Abilitato = 1
	WHERE
		(@Cognome IS NULL OR P.Cognome LIKE @Cognome + '%')
		AND (@Nome IS NULL OR P.Nome LIKE @Nome + '%')
		AND (@AnnoNascita IS NULL or YEAR(P.DataNascita) = @AnnoNascita)
		AND (@CodiceFiscale IS NULL OR P.CodiceFiscale = @CodiceFiscale)	
		AND (P.Disattivato = 0) --Dall'interfaccia USER si restituiscono solo le anagrafiche ATTIVE
		AND (P.Occultato = 0)
	ORDER BY P.Cognome, P.Nome
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiLista1] TO [DataAccessUi]
    AS [dbo];

