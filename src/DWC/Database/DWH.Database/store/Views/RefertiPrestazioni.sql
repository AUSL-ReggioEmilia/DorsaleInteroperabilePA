

CREATE VIEW [store].[RefertiPrestazioni]
AS
/*
	Tutti i REFERTI+PRESTAZIONI a livello di singlo STORE
	
	NUOVA SANDRO 2015-05-13: Copiata da RefertiPrestazioneTutti
	MODIFICA SANDRO 2015-09-16: Aggiunti R.IdEsterno, R.SpecialitaErogante, P.IDEsterno, P.GravitaCodice, P.GravitaDescrizione
*/
	SELECT R.ID AS IdRefertiBase ,R.DataPartizione ,R.IdEsterno AS IdEsternoReferto ,R.IdPaziente
		,R.DataInserimento, R.DataModifica
		,R.AziendaErogante ,R.SistemaErogante ,R.RepartoErogante, R.SpecialitaErogante ,R.StrutturaEroganteCodice
		,R.DataReferto ,R.DataEvento ,R.NumeroReferto ,R.NumeroNosologico ,R.NumeroPrenotazione ,R.IdOrderEntry
		,R.RepartoRichiedenteCodice ,R.RepartoRichiedenteDescr ,R.StatoRichiestaCodice
		,R.Referto ,R.Firmato ,R.Confidenziale
		,P.Attributi AS AttributiReferto
		
		,P.ID AS IdPrestazioneBase ,P.IDEsterno AS IDEsternoPrestazione
		,P.DataErogazione
		,P.SezioneCodice ,P.SezioneDescrizione
		,P.PrestazioneCodice ,P.PrestazioneDescrizione
		,P.SezionePosizione, P.PrestazionePosizione
		,P.Commenti	,P.Risultato ,P.ValoriRiferimento
		,P.Quantita	,P.UnitaDiMisura
		,P.GravitaCodice, P.GravitaDescrizione
		,P.RangeValoreMinimo ,P.RangeValoreMassimo
		,P.RangeValoreMinimoUnitaDiMisura ,P.RangeValoreMassimoUnitaDiMisura
		,P.Attributi AS AttributiPrestazione
	FROM 
		dbo.Referti_History R
		INNER JOIN dbo.Prestazioni_History P
			ON R.ID = P.IdRefertiBase
				AND R.DataPartizione = P.DataPartizione

	UNION ALL
	
	SELECT R.ID AS IdRefertiBase ,R.DataPartizione ,R.IdEsterno AS IdEsternoReferto ,R.IdPaziente
		,R.DataInserimento, R.DataModifica
		,R.AziendaErogante ,R.SistemaErogante ,R.RepartoErogante, R.SpecialitaErogante ,R.StrutturaEroganteCodice
		,R.DataReferto ,R.DataEvento ,R.NumeroReferto ,R.NumeroNosologico ,R.NumeroPrenotazione ,R.IdOrderEntry
		,R.RepartoRichiedenteCodice ,R.RepartoRichiedenteDescr ,R.StatoRichiestaCodice
		,R.Referto ,R.Firmato ,R.Confidenziale
		,P.Attributi AS AttributiReferto
		
		,P.ID AS IdPrestazioneBase ,P.IDEsterno AS IDEsternoPrestazione
		,P.DataErogazione
		,P.SezioneCodice ,P.SezioneDescrizione
		,P.PrestazioneCodice ,P.PrestazioneDescrizione
		,P.SezionePosizione, P.PrestazionePosizione
		,P.Commenti	,P.Risultato ,P.ValoriRiferimento
		,P.Quantita	,P.UnitaDiMisura
		,P.GravitaCodice, P.GravitaDescrizione
		,P.RangeValoreMinimo ,P.RangeValoreMassimo
		,P.RangeValoreMinimoUnitaDiMisura ,P.RangeValoreMassimoUnitaDiMisura
		,P.Attributi AS AttributiPrestazione
	FROM 
		dbo.Referti_Recent R
		INNER JOIN dbo.Prestazioni_Recent P
			ON R.ID = P.IdRefertiBase
				AND R.DataPartizione = P.DataPartizione
