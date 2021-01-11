
/*
	CREATA SANDRO 2015-02-04: Lista dei referti OSCURATI sul DWH 
											o CONFIDENZIALI dall'erogante
											o CANCELLATI sul DWH
	MODIFICA ETTORE 2015-03-06: nuovo filtro di oscuramento dbo.GetRefertiIsOscurato2() per oscurati da DWH
	MODIFICA SANDRO 2015-09-31: Vista di compatibilità - Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA CHIAMATA A FUNCTION OSCURAMENTI
	MODIFICA SANDRO 2016-06-07: Aggiunta FUNZIONE OSCURAMENTI Massivi e i cancellati sono negli oscuramenti
*/
CREATE VIEW [dbo].[RefertiNascosti]
AS
	SELECT  Referti.ID,
		Referti.DataPartizione,
		Referti.IdEsterno,
		Referti.IdPaziente,
		Referti.DataInserimento,
		Referti.DataModifica,
		Referti.AziendaErogante,
		Referti.SistemaErogante,
		Referti.RepartoErogante,
		Referti.DataReferto,
		Referti.DataEvento,
		Referti.NumeroReferto,
		Referti.NumeroNosologico,
		Referti.NumeroPrenotazione,
		Referti.IdOrderEntry,
		Referti.Firmato,
	
		-- CANCELLATO
		CASE WHEN EXISTS (SELECT * FROM [dbo].[Oscuramenti] WHERE [IdEsternoReferto] = Referti.IdEsterno) THEN 1
				ELSE 0 END AS Cancellato,
	
		-- CONFIDENZIALE
		dbo.GetRefertiIsConfidenziale(Referti.Id, Referti.DataPartizione) AS Confidenziale,
	
		-- OSCURATO	
		CASE 
			-- Cancellato paziente
			WHEN EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK)
						WHERE PazientiCancellati.IdPazientiBase = Referti.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) THEN 'Paziente'
			
			-- Oscuramento puntuale
			WHEN dbo.GetRefertoOscuramentiPuntuali(Referti.IdEsterno 
									, Referti.AziendaErogante
									, Referti.SistemaErogante
									, Referti.NumeroNosologico 
									, Referti.NumeroPrenotazione
									, Referti.NumeroReferto
									, Referti.IdOrderEntry	) = 1 THEN 'Referto'
			-- Oscuramento massivo
			WHEN EXISTS (SELECT * FROM  dbo.GetRefertoOscuramenti(Referti.Id, Referti.DataPartizione
									, Referti.AziendaErogante, Referti.SistemaErogante
									, Referti.StrutturaEroganteCodice
									, Referti.NumeroNosologico, Referti.RepartoRichiedenteCodice
									, Referti.RepartoErogante, Referti.Confidenziale) ) THEN 'Massivo'
		
			ELSE NULL END AS Oscurato

	FROM 
		[store].[Referti] AS Referti WITH(NOLOCK)
	
	WHERE
		-- Oscuramento puntuale
		dbo.GetRefertoOscuramentiPuntuali(Referti.IdEsterno 
									, Referti.AziendaErogante
									, Referti.SistemaErogante
									, Referti.NumeroNosologico 
									, Referti.NumeroPrenotazione
									, Referti.NumeroReferto
									, Referti.IdOrderEntry	) = 1
	
		-- Confidenziale							
		OR dbo.GetRefertiIsConfidenziale(Referti.Id, Referti.DataPartizione) = 1
	
		-- Oscuramento massivo
		OR EXISTS (SELECT * FROM dbo.GetRefertoOscuramenti(Referti.Id, Referti.DataPartizione
														, Referti.AziendaErogante, Referti.SistemaErogante
														, Referti.StrutturaEroganteCodice
														, Referti.NumeroNosologico, Referti.RepartoRichiedenteCodice
														, Referti.RepartoErogante, Referti.Confidenziale)
					)

		-- Cancellato referto
		OR EXISTS (SELECT * FROM [dbo].[Oscuramenti] WHERE [IdEsternoReferto] = Referti.IdEsterno)

		-- Cancellato paziente
		OR EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK) 
						WHERE PazientiCancellati.IdPazientiBase = Referti.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL)



GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiNascosti] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiNascosti] TO [DataAccessSql]
    AS [dbo];

