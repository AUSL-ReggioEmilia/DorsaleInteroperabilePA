
CREATE VIEW [dbo].[ConsensiSpResult]
AS
/*
	MODIFICA ETTORE 2014-05-15: 
		La SP restituiva solo i consensi associati ad una posizione attiva/padre
		La nuova versione trasla l'IdPAzienteFuso nell'IdPazientePadre
	
	MODIFICA ETTORE 2016-01-12: gestione del nuovo campo Attributi

*/
	SELECT    
		  CPA.Id
		, CPA.Provenienza
		, CPA.IdProvenienza
		--
		-- Bisogna usare l'Id della tabella Pazienti e non quello della tabella Consesni
		-- altrimenti la query è più lenta
		-- Faccio IL CAST per evitare che il table adapter crei una key univoca sul campo
		--
		, CAST(Pazienti.Id AS UNIQUEIDENTIFIER) AS IdPaziente  --questo è l'attivo
		
		, CPA.IdTipo
		, ConsensiTipo.Nome AS Tipo
		, CPA.DataStato
		, CPA.Stato
		, CPA.OperatoreId
		, CPA.OperatoreCognome
		, CPA.OperatoreNome
		, CPA.OperatoreComputer
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
		-- restituisco anche l'Id del paziente figlio a cui era associato il consenso
		, CPA.IdPazienteFuso				
		, CPA.Attributi
	FROM
		--in questa sono già traslati gli id paziente fusi in IdAttivi
		ConsensiPazientiAggregati AS CPA with(nolock)
		INNER JOIN ConsensiTipo with(nolock) 
			ON CPA.IdTipo = dbo.ConsensiTipo.Id
		INNER JOIN Pazienti with(nolock) --questa fa rallentare usa un indice IX_CodiceFiscaleMedicoDIBase
			ON Pazienti.Id = CPA.IdPaziente
		LEFT OUTER JOIN IstatComuni with(nolock)
			ON Pazienti.ComuneNascitaCodice = IstatComuni.Codice
		LEFT OUTER JOIN IstatNazioni with(nolock)
			ON Pazienti.NazionalitaCodice = IstatNazioni.Codice

