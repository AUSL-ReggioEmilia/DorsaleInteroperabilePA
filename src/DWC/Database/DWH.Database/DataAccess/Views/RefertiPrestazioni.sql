
CREATE VIEW [DataAccess].[RefertiPrestazioni] AS
/*
	CREATA DA SANDRO 2015-09-16: 
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

		, R.[IdPrestazioneBase]
		, R.[IdEsternoPrestazione]
		, R.[DataErogazione]
		, R.[PrestazioneCodice], R.[PrestazioneDescrizione]
		, R.[SezioneCodice], R.[SezioneDescrizione]
		, R.[GravitaCodice], R.[GravitaDescrizione]
		, R.[Risultato], R.[ValoriRiferimento]
		, R.[SezionePosizione], R.[PrestazionePosizione]
		, R.[Commenti]

		, R.[Quantita], R.[UnitaDiMisura]
		, R.[RangeValoreMinimo], R.[RangeValoreMassimo]
		, R.[RangeValoreMinimoUnitaDiMisura], R.[RangeValoreMassimoUnitaDiMisura]

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		, CONVERT(NVARCHAR(MAX), R.AttributiPrestazione) AS AttributiPrestazione

	FROM [store].[RefertiPrestazioni] AS R WITH(NOLOCK)


