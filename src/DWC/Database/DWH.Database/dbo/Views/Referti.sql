

-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce i referti
-- Modify date: 2014-05-30 - ETTORE: Gestione DataEvento e Firmato 
--										Aggiunto anche i campi IdOrderEntry e DataPartizione 
-- Modify date: 2014-10-13 - ETTORE: aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti
-- Modify date: 2015-03-03 - ETTORE: uso delle function GetRefertiAttributo2() e GetRefertiAttributo2DateTime() + nuovo filtro oscuramento
-- Modify date: 2015-09-31 - SANDRO: Vista di compatibilità
--										Accede tramite lo schema STORE
-- Modify date: 2015-09-23 - STEFANO: SOSTITUITA CHIAMATA A FUNCTION OSCURAMENTI
-- Modify date: 2019-01-31 - ETTORE: Eliminato l'uso della tabella "dbo.RepartiEroganti"
-- =============================================
CREATE VIEW [dbo].[Referti]
AS
	SELECT  Referti.ID,
		Referti.IdEsterno,
		Referti.IdPaziente,
		Referti.DataInserimento,
		Referti.DataModifica,
		Referti.AziendaErogante,
		Referti.SistemaErogante,
		Referti.RepartoErogante,
		Referti.DataReferto,
		Referti.NumeroReferto,
		Referti.NumeroNosologico,
		Referti.NumeroPrenotazione,

		Referti.Cognome,
		Referti.Nome,
		Referti.Sesso,
		Referti.CodiceFiscale,
		Referti.DataNascita,
		Referti.ComuneNascita,
		CONVERT(VARCHAR(4), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'ProvinciaNascita')) AS ProvinciaNascita,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'ComuneResidenza')) AS ComuneResidenza,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'CodiceSAUB')) AS CodiceSAUB,
		Referti.CodiceSanitario,

		Referti.NomeStile,
	
		Referti.RepartoRichiedenteCodice,
		Referti.RepartoRichiedenteDescr,

		'' AS RepartoRichiedenteRuoloVisualizzazione,

		CONVERT(VARCHAR(16), Referti.StatoRichiestaCodice) AS StatoRichiestaCodice,
	
		dbo.GetRefertoStatoDesc(Referti.RepartoErogante, 
						CONVERT(VARCHAR(16), Referti.StatoRichiestaCodice),
						Referti.StatoRichiestaDescr 
					) AS StatoRichiestaDescr,

		Referti.PrioritaCodice,
		Referti.PrioritaDescr,

		Referti.TipoRichiestaCodice,
		Referti.TipoRichiestaDescr,

		Referti.Referto,

		Referti.MedicoRefertanteCodice,
		Referti.MedicoRefertanteDescr,

		dbo.GetRuoloVisualizzazioneRefertiRepartoRichiedente(
				Referti.AziendaErogante,
				Referti.SistemaErogante,
				Referti.RepartoRichiedenteCodice) AS RuoloVisualizzazioneRepartoRichiedente,

		dbo.GetRuoloVisualizzazioneRefertiSistemaErogante(
										Referti.AziendaErogante,
										Referti.SistemaErogante) AS RuoloVisualizzazioneSistemaErogante,
		--									
		-- Aggiungo nuovi campi
		--
		IdOrderEntry,
		DataPartizione,
		DataEvento,
		Firmato	

	FROM [store].[Referti] AS Referti

	WHERE	Referti.StatoRichiestaCodice <> 3	-- Non gli annullati
		--AND Referti.Cancellato = 0			-- Non applicabile: Lo schema STORE già non torna i cancellati
		--
		-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
		--
		AND NOT EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = Referti.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL)
		--
		-- Nascondo i Conficenziali
		--
		AND dbo.GetRefertiIsConfidenziale(Referti.Id, Referti.DataPartizione) = 0
		--
		--
		--		
		AND dbo.GetRefertoOscuramentiPuntuali(Referti.IdEsterno 
									, Referti.AziendaErogante
									, Referti.SistemaErogante
									, Referti.NumeroNosologico 
									, Referti.NumeroPrenotazione
									, Referti.NumeroReferto
									, Referti.IdOrderEntry	) = 0




GO
GRANT SELECT
    ON OBJECT::[dbo].[Referti] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Referti] TO [DataAccessSql]
    AS [dbo];

