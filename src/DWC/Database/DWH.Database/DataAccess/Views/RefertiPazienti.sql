
CREATE VIEW [DataAccess].[RefertiPazienti] AS
/*
	CREATA DA SANDRO 2020-03-20: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.RefertiPrestazioni

	MODIFICATE 2016-10-07 SANDRO: Converto in nVARCHAR perche XML non permette le query distribuite

*/
	SELECT	
		  R.IdRefertiBase, R.DataPartizione
		, R.IdEsternoReferto
		, R.IdPaziente
		, R.DataInserimento, R.DataModifica
		, R.AziendaErogante, R.SistemaErogante, R.RepartoErogante, R.SpecialitaErogante, R.StrutturaEroganteCodice
		, R.DataReferto, R.DataEvento, R.NumeroReferto, R.NumeroNosologico, R.NumeroPrenotazione, R.IdOrderEntry
		, R.Referto ,R.Firmato

		, R.RepartoRichiedenteCodice, R.RepartoRichiedenteDescr AS RepartoRichiedenteDescrizione

		, R.StatoRichiestaCodice , dbo.GetRefertoStatoDesc(R.RepartoErogante, 
																CONVERT(VARCHAR(16), R.StatoRichiestaCodice),
																NULL 
															) AS StatoRichiestaDescrizione

		, CASE WHEN R.StatoRichiestaCodice = 3
				THEN 1 ELSE 0 END AS Annullato
	
		, R.Confidenziale

		, CASE WHEN EXISTS (SELECT * FROM  dbo.GetRefertoOscuramenti(R.IdRefertiBase, R.DataPartizione, R.AziendaErogante
						, R.SistemaErogante, R.StrutturaEroganteCodice
						, R.NumeroNosologico, R.RepartoRichiedenteCodice
						, R.RepartoErogante, R.Confidenziale)
							)
				THEN 1 ELSE 0 END AS OscuratoMassivo

		, CASE WHEN dbo.GetRefertoOscuramentiPuntuali(R.IdEsternoReferto, R.AziendaErogante, R.SistemaErogante
						, R.NumeroNosologico, R.NumeroPrenotazione
						, R.NumeroReferto, R.IdOrderEntry) = 1
				THEN 1 ELSE 0 END AS OscuratoPuntuale
			
		, CASE WHEN EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = R.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) 
						
				THEN 1 ELSE 0 END AS OscuratoPaziente

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		, CONVERT(NVARCHAR(MAX), R.AttributiReferto) AS AttributiReferto

		,R. [SacPazienteCognome]
		,R. [SacPazienteNome]
		,R. [SacPazienteCodiceFiscale]
		,R. [SacPazienteDataNascita]
		,R. [SacPazienteSesso]
		,R. [SacPazienteLuogoNascitaCodice]
		,R. [SacPazienteLuogoNascita]

	FROM [store].[RefertiPazienti] AS R WITH(NOLOCK)