
CREATE VIEW [dbo].[ConsensiOutput]
AS
/*
	MODIFICA ETTORE 2012-09-12
	Restituisce i consensi aggregati associandoli ai pazienti a cui il consenso è associato
	cioè l'IdPaziente può essere di una posizione attiva o fusa
	Inoltre esegue una LEFT JOIN con le tabelle ISTAT, in quando non è detto che i campi ISTAT 
	siano compilati
	
	Ettore 2014-05-23
		ATTENZIONE: E' corretto che la vista restituisca i dati aggregati per IdPaziente dove IdPaziente può essere sia un padre che un figlio.
		La vista è stata pensata per restituire dei dati grezzi.
		Non deve restituire i consensi di una catena di fusione associati al padre della fusione, ma deve restituire i consensi associati ad
		ogni anagrafica.
	Sandro 2015-06-24	Aggiunto campo MetodoAssociazione

	Sandro 2016-05-26 SANDRO Rimosso WHERE LeggePazientiPermessiLettura()=1
*/
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
	, Consensi.MetodoAssociazione AS MetodoAssociazione
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
    ON OBJECT::[dbo].[ConsensiOutput] TO [DataAccessSql]
    AS [dbo];

