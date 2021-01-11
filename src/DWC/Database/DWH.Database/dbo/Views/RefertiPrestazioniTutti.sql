


/*
	MODIFICA ETTORE 2014-06-18: Aggiunto i campi DataEvento, Firmato
	
	MODIFICA ETTORE 2014-10-13: 
		1)	Aggiunto il campo IdOrderEntry
		2)	Aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti (richiede IdOrderEntry)
	MODIFICA ETTORE 2015-03-06: nuovo filtro di oscuramento dbo.GetRefertiIsOscurato2() per oscurati da DWH		

	MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA CHIAMATA A FUNCTION OSCURAMENTI
*/
CREATE VIEW [dbo].[RefertiPrestazioniTutti]
AS
	SELECT 
		Referti.IdRefertiBase AS ID, 
		Referti.DataPartizione, 
		Referti.IdPaziente, 
		Referti.AziendaErogante, 
		Referti.SistemaErogante, 
		Referti.RepartoErogante,
		Referti.DataReferto, 
		Referti.NumeroReferto, 
		Referti.NumeroNosologico,
		Referti.NumeroPrenotazione,
		Referti.RepartoRichiedenteCodice,
		Referti.RepartoRichiedenteDescr,
		Referti.StatoRichiestaCodice,

		Referti.IdPrestazioneBase, 
		Referti.SezioneCodice AS PrestazioneSezioneCodice,
		Referti.SezioneDescrizione AS PrestazioneSezioneDescrizione, 
		Referti.PrestazioneCodice AS PrestazioneCodice,
		Referti.PrestazioneDescrizione AS PrestazioneDescrizione,

		Referti.Risultato,
		Referti.Quantita,
		Referti.DataErogazione AS PrestazioneDataErogazione,
		--
		-- Nuovi campi
		--
		Referti.DataEvento,
		Referti.Firmato,
		Referti.IdOrderEntry
	FROM 
		store.RefertiPrestazioni Referti WITH(NOLOCK)

	WHERE dbo.GetRefertoOscuramentiPuntuali(Referti.IdEsternoReferto
									, Referti.AziendaErogante
									, Referti.SistemaErogante
									, Referti.NumeroNosologico 
									, Referti.NumeroPrenotazione
									, Referti.NumeroReferto
									, Referti.IdOrderEntry	) = 0




GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiPrestazioniTutti] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiPrestazioniTutti] TO [DataAccessSql]
    AS [dbo];

