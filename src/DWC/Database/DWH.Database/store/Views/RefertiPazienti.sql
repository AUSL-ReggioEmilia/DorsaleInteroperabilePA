

CREATE VIEW [store].[RefertiPazienti]
AS
/*
	Tutti i REFERTI+PAZIENTI a livello di singlo STORE
	
	NUOVA SANDRO 2020-03-220: Da usare nella DataAccess
*/
	SELECT R.ID AS IdRefertiBase ,R.DataPartizione ,R.IdEsterno AS IdEsternoReferto ,R.IdPaziente
		,R.DataInserimento, R.DataModifica
		,R.AziendaErogante ,R.SistemaErogante ,R.RepartoErogante, R.SpecialitaErogante ,R.StrutturaEroganteCodice
		,R.DataReferto ,R.DataEvento ,R.NumeroReferto ,R.NumeroNosologico ,R.NumeroPrenotazione ,R.IdOrderEntry
		,R.RepartoRichiedenteCodice ,R.RepartoRichiedenteDescr ,R.StatoRichiestaCodice
		,R.Referto ,R.Firmato ,R.Confidenziale
		,R.Attributi AS AttributiReferto

		,P.[Cognome] AS [SacPazienteCognome]
		,P.[Nome] AS [SacPazienteNome]
		,P.[CodiceFiscale] AS [SacPazienteCodiceFiscale]
		,P.[DataNascita] AS [SacPazienteDataNascita]
		,P.[Sesso] AS [SacPazienteSesso]

		,P.[LuogoNascitaCodice] AS [SacPazienteLuogoNascitaCodice]
		,P.[LuogoNascitaDescrizione] AS [SacPazienteLuogoNascita]

	FROM 
		dbo.Referti_History R
		INNER JOIN [sac].[Pazienti] P
			ON R.IdPaziente = P.Id

	UNION ALL

	SELECT R.ID AS IdRefertiBase ,R.DataPartizione ,R.IdEsterno AS IdEsternoReferto ,R.IdPaziente
		,R.DataInserimento, R.DataModifica
		,R.AziendaErogante ,R.SistemaErogante ,R.RepartoErogante, R.SpecialitaErogante ,R.StrutturaEroganteCodice
		,R.DataReferto ,R.DataEvento ,R.NumeroReferto ,R.NumeroNosologico ,R.NumeroPrenotazione ,R.IdOrderEntry
		,R.RepartoRichiedenteCodice ,R.RepartoRichiedenteDescr ,R.StatoRichiestaCodice
		,R.Referto ,R.Firmato ,R.Confidenziale
		,R.Attributi AS AttributiReferto

		,P.[Cognome] AS [SacPazienteCognome]
		,P.[Nome] AS [SacPazienteNome]
		,P.[CodiceFiscale] AS [SacPazienteCodiceFiscale]
		,P.[DataNascita] AS [SacPazienteDataNascita]
		,P.[Sesso] AS [SacPazienteSesso]

		,P.[LuogoNascitaCodice] AS [SacPazienteLuogoNascitaCodice]
		,P.[LuogoNascitaDescrizione] AS [SacPazienteLuogoNascita]

	FROM 
		dbo.Referti_Recent R
		INNER JOIN [sac].[Pazienti] P
			ON R.IdPaziente = P.Id