


-- =============================================
-- Author:		Ettore
-- Create date: 2012-09-12
-- Description:	derivata dalla ConsensiOutput per esporre anche gli Attributi
--		Il campo Attributi è nel formato: 
--			<Attributi>
--				<Attributo Nome="Nome1" Valore="Valore1" />
--				<Attributo Nome="Nome2" Valore="Valore2" />
--				...
--				<Attributo Nome="NomeN" Valore="ValoreN" />
--			</Attributi>	
-- Modify date: 2016-05-26 SANDRO Rimosso WHERE LeggePazientiPermessiLettura()=1
-- Modify date: 2016-10-14 ETTORE Restituito il campo XML degli Attributi come NVARCHAR(MAX)
-- Modify date: 2018-09-17 ETTORE Aggiunto il nome della tabella "Consensi" in , CAST(Consensi.Attributi AS NVARCHAR(MAX)) AS Attributi, poichè ora c'è campo Attributi anche nella tabella "Pazienti"
-- =============================================
CREATE VIEW [dbo].[ConsensiOutput2]
AS
SELECT    
	  Consensi.Id
	, Consensi.Provenienza
	, Consensi.IdProvenienza
	, Consensi.IdPaziente --questo può essere un Id di un paziente attivo o di un fuso
	, ConsensiTipo.Nome AS Tipo
	, Consensi.DataStato
	, Consensi.Stato
	, Consensi.OperatoreId
	, Consensi.OperatoreCognome
	, Consensi.OperatoreNome
	, Consensi.OperatoreComputer
	, Pazienti.Provenienza AS PazienteProvenienza
	, Pazienti.IdProvenienza AS PazienteIdProvenienza
	, Pazienti.Cognome AS PazienteCognome
	, Pazienti.Nome AS PazienteNome
	, Pazienti.Tessera AS PazienteTessera
	, Pazienti.CodiceFiscale AS PazienteCodiceFiscale
	, Pazienti.DataNascita AS PazienteDataNascita
	, Pazienti.ComuneNascitaCodice AS PazienteComuneNascitaCodice
	, IstatComuni.Nome AS PazienteComuneNascitaNome
	, Pazienti.NazionalitaCodice AS PazienteNazionalitaCodice
	, IstatNazioni.Nome AS PazienteNazionalitaNome
	--Nuovo campo Attributi
	, CAST(Consensi.Attributi AS NVARCHAR(MAX)) AS Attributi
FROM
	Consensi with(nolock)
	INNER JOIN ConsensiAggregati with(nolock)
		ON Consensi.Id = ConsensiAggregati.Id
	INNER JOIN Pazienti with(nolock)
		ON Pazienti.Id = Consensi.IdPaziente
			
	INNER JOIN ConsensiTipo with(nolock) 
		ON dbo.Consensi.IdTipo = dbo.ConsensiTipo.Id
		
	LEFT OUTER JOIN IstatComuni with(nolock)
		ON Pazienti.ComuneNascitaCodice = IstatComuni.Codice
		
	LEFT OUTER JOIN IstatNazioni with(nolock)
		ON Pazienti.NazionalitaCodice = IstatNazioni.Codice

WHERE Consensi.IdPAziente <> '00000000-0000-0000-0000-000000000000'
GO
GRANT SELECT
    ON OBJECT::[dbo].[ConsensiOutput2] TO [DataAccessSql]
    AS [dbo];

