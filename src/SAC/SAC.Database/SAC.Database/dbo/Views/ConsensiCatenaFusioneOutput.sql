

CREATE VIEW [dbo].[ConsensiCatenaFusioneOutput]
AS
/*
	MODIFICA ETTORE 2016-10-12: tolto il campo CPA.MetodoAssociazione
	MODIFICA SANDRO 2016-10-18: Conversione campo XML in nvarchar
*/
	SELECT 
		CPA.Id
		, CPA.Provenienza		--Provenienza del consesno
		, CPA.IdProvenienza		--IdProvenienza del consesno
		, CPA.IdPaziente		--L'id del paziente attivo, il padre della catena di fusione
		, CPA.IdPazienteFuso	--Se <> NULL il consenso è associato ad una anagrafica figlia
		, CT.Nome AS Tipo		--Il nome del consenso
		, CPA.DataStato
		, CPA.Stato
		, CPA.OperatoreId
		, CPA.OperatoreCognome
		, CPA.OperatoreNome
		, CPA.OperatoreComputer
		, P.Provenienza AS PazienteProvenienza		--Provenienza del paziente attivo
		, P.IdProvenienza AS PazienteIdProvenienza	--IdProvenienza del paziente attivo
		, P.Cognome AS PazienteCognome				--Dati anagrafici del paziente attivo
		, P.Nome AS PazienteNome
		, P.Tessera AS PazienteTessera
		, P.CodiceFiscale AS PazienteCodiceFiscale
		, P.DataNascita AS PazienteDataNascita
		, P.ComuneNascitaCodice AS PazienteComuneNascitaCodice
		, IstatComuni.Nome AS PazienteComuneNascitaNome
		, P.NazionalitaCodice AS PazienteNazionalitaCodice
		, IstatNazioni.Nome AS PazienteNazionalitaNome
		, CONVERT(NVARCHAR(MAX), CPA.Attributi) AS Attributi
	FROM 
		ConsensiPazientiAggregati AS CPA WITH(NOLOCK)
		INNER JOIN ConsensiTipo AS CT WITH(NOLOCK)
			ON CT.Id = CPA.IdTipo
		INNER JOIN Pazienti AS P WITH(NOLOCK)
			ON P.Id = CPA.IdPaziente
		LEFT OUTER JOIN IstatComuni WITH(NOLOCK)
			ON P.ComuneNascitaCodice = IstatComuni.Codice
		LEFT OUTER JOIN IstatNazioni with(nolock)
			ON P.NazionalitaCodice = IstatNazioni.Codice
	WHERE CPA.IdPAziente <> '00000000-0000-0000-0000-000000000000'
GO
GRANT SELECT
    ON OBJECT::[dbo].[ConsensiCatenaFusioneOutput] TO [DataAccessSql]
    AS [dbo];

