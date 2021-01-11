-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-10-26
-- Description: Vista per leggere i consensi validi del paziente
-- Modify date: 
-- =============================================
CREATE VIEW [pazienti_ws].[Consensi]
AS
	SELECT    
		  CPA.Id
		, CPA.Provenienza
		, CPA.IdProvenienza		
		, CPA.IdPaziente AS IdPaziente  --questo è l'attivo		
		, CPA.IdTipo
		, ConsensiTipo.Nome AS Tipo
		, CPA.DataStato
		, CPA.Stato
		, CPA.OperatoreId
		, CPA.OperatoreCognome
		, CPA.OperatoreNome
		, CPA.OperatoreComputer	
		, CPA.Attributi
	FROM
		--in questa sono già traslati gli id paziente fusi in IdAttivi
		dbo.ConsensiPazientiAggregati AS CPA with(nolock)
		INNER JOIN dbo.ConsensiTipo with(nolock) 
			ON CPA.IdTipo = dbo.ConsensiTipo.Id