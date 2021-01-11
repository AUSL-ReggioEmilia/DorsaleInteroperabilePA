
CREATE VIEW [DataAccess].[Referti] AS
/*
	CREATA DA SANDRO 2015-05-22: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.Referti
*/
	SELECT	
		  R.ID, R.DataPartizione, R.IdEsterno, R.IdPaziente
		, R.DataInserimento, R.DataModifica
		, R.AziendaErogante, R.SistemaErogante, R.RepartoErogante, R.SpecialitaErogante, R.StrutturaEroganteCodice
		, R.DataReferto, R.DataEvento, R.NumeroReferto, R.NumeroNosologico, R.NumeroPrenotazione, R.IdOrderEntry
		, R.Firmato , R.Referto, R.Anteprima

		, R.RepartoRichiedenteCodice, R.RepartoRichiedenteDescr AS RepartoRichiedenteDescrizione
		
		, R.StatoRichiestaCodice , dbo.GetRefertoStatoDesc(R.RepartoErogante, 
																CONVERT(VARCHAR(16), R.StatoRichiestaCodice),
																R.StatoRichiestaDescr 
															) AS StatoRichiestaDescrizione

		, R.NomeStile
		, R.Cognome, R.Nome, R.Sesso, R.CodiceFiscale, R.DataNascita, R.ComuneNascita, R.CodiceSanitario
		
		, R.PrioritaCodice, R.PrioritaDescr AS PrioritaDescrizione
		, R.TipoRichiestaCodice, R.TipoRichiestaDescr AS TipoRichiestaDescrizione
		, R.MedicoRefertanteCodice, R.MedicoRefertanteDescr AS MedicoRefertanteDescrizione
		
		, CASE WHEN R.StatoRichiestaCodice = 3
				THEN 1 ELSE 0 END AS Annullato
	
		, R.Confidenziale

		, CASE WHEN EXISTS (SELECT * FROM  dbo.GetRefertoOscuramenti(R.Id, R.DataPartizione, R.AziendaErogante
						, R.SistemaErogante, R.StrutturaEroganteCodice
						, R.NumeroNosologico, R.RepartoRichiedenteCodice
						, R.RepartoErogante, R.Confidenziale)
							)
				THEN 1 ELSE 0 END AS OscuratoMassivo

		, CASE WHEN dbo.GetRefertoOscuramentiPuntuali(R.IdEsterno, R.AziendaErogante, R.SistemaErogante
						, R.NumeroNosologico, R.NumeroPrenotazione
						, R.NumeroReferto, R.IdOrderEntry) = 1
				THEN 1 ELSE 0 END AS OscuratoPuntuale
			
		, CASE WHEN EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = R.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) 
						
				THEN 1 ELSE 0 END AS OscuratoPaziente

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		, CONVERT(NVARCHAR(MAX), R.Attributi) AS Attributi

	FROM [store].[Referti] AS R WITH(NOLOCK)
