
/*
	MODIFICA ETTORE 2014-06-18: Aggiunto camoi DataEvento, Firmato
	MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[RefertiPrestazioni]
AS
	SELECT 
		Referti.ID, 
		Referti.IdPaziente, 
		Referti.AziendaErogante, 
		Referti.SistemaErogante, 
		Referti.RepartoErogante,
		Referti.DataReferto, 
		Referti.NumeroReferto, 
		Referti.RepartoRichiedenteCodice,
		Referti.RepartoRichiedenteDescr,
		Referti.StatoRichiestaCodice, 
		Referti.StatoRichiestaDescr, 
		Referti.TipoRichiestaCodice,
		Referti.TipoRichiestaDescr,

		Prestazioni.ID AS IdPrestazioneBase, 
		Prestazioni.SezioneCodice AS PrestazioneSezioneCodice,
		Prestazioni.SezioneDescrizione AS PrestazioneSezioneDescrizione, 
		Prestazioni.PrestazioneCodice AS PrestazioneCodice,
		Prestazioni.PrestazioneDescrizione AS PrestazioneDescrizione, 	
		Prestazioni.SoundexPrestazione AS PrestazioneSoundexPrestazione, 
		Prestazioni.SoundexSezione AS PrestazioneSoundexSezione,
		--
		-- Nuovi campi
		--
		Referti.DataEvento,
		Referti.Firmato
	FROM	
		store.Referti 
		INNER JOIN	store.Prestazioni  AS Prestazioni 
			ON Referti.ID = Prestazioni.IdRefertiBase

GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiPrestazioni] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiPrestazioni] TO [DataAccessSql]
    AS [dbo];

