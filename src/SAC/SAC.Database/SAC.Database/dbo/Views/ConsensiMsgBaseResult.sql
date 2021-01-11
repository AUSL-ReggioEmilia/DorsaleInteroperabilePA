
CREATE VIEW [dbo].[ConsensiMsgBaseResult]
AS
SELECT    Consensi.Id
		, Consensi.DataDisattivazione
		, Consensi.Disattivato
		, Consensi.Provenienza
		, Consensi.IdProvenienza
		, Consensi.IdPaziente
		, ConsensiTipo.Nome AS Tipo
		, Consensi.DataStato
		, Consensi.Stato
		, Consensi.OperatoreId
		, Consensi.OperatoreCognome
		, Consensi.OperatoreNome
		, Consensi.OperatoreComputer
		, dbo.Pazienti.Id AS PazienteId
		, dbo.Pazienti.Provenienza AS PazienteProvenienza
		, dbo.Pazienti.IdProvenienza AS PazienteIdProvenienza
		, dbo.Pazienti.Cognome AS PazienteCognome
		, dbo.Pazienti.Nome AS PazienteNome
		, dbo.Pazienti.Tessera AS PazienteTessera
		, dbo.Pazienti.CodiceFiscale AS PazienteCodiceFiscale
		, dbo.Pazienti.DataNascita AS PazienteDataNascita
		, dbo.Pazienti.ComuneNascitaCodice AS PazienteComuneNascitaCodice
		, dbo.Pazienti.NazionalitaCodice AS PazienteNazionalitaCodice

FROM  dbo.Consensi INNER JOIN dbo.ConsensiTipo
	ON dbo.Consensi.IdTipo = dbo.ConsensiTipo.Id
INNER JOIN dbo.Pazienti
	ON dbo.Consensi.IdPaziente = dbo.Pazienti.Id
