



CREATE VIEW [frontend].[Referti]
AS
/*
	CREATA DA ETTORE 2015-05-21: 
		Utilizzo nuove viste nello schema "store"			
		Ho tolto tutti i campi che venivano restituiti per compatibilità e i campi non utilizzati:
			ProvinciaNascita, ComuneResidenza, CodiceSAUB, 
			RuoloVisualizzazioneRepartoRichiedente, RuoloVisualizzazioneSistemaErogante
		Non si filtra più per Cancellato=0 perché lo fa la vista “store”
		Tolto filtro su pazienti cancellati per reparto erogante (non in uso in PROD)
		Aggiunto filtro su OscuramentiPuntuali
		Aggiunto restituzione degli oscuramenti a cui è soggetto il referto dbo.GetRefertoOscuramentiXML()
		Il campo StatoRichiestaCodice lo restituisco come TINYINT

*/
SELECT
	R.ID
	, R.DataPartizione
	, R.IdEsterno
	, R.IdPaziente
	, R.DataInserimento
	, R.DataModifica
	, R.AziendaErogante
	, R.SistemaErogante
	, R.RepartoErogante
	, R.DataReferto
	, R.DataEvento	
	, R.NumeroReferto
	, R.NumeroNosologico
	, R.NumeroPrenotazione
	, R.IdOrderEntry
	, R.Firmato
	, R.RepartoRichiedenteCodice
	, R.RepartoRichiedenteDescr

	, R.StatoRichiestaCodice		----------------
	, dbo.GetRefertoStatoDesc(R.RepartoErogante, 
					CONVERT(VARCHAR(16), R.StatoRichiestaCodice),
					R.StatoRichiestaDescr 
				) AS StatoRichiestaDescr
	, CAST(R.NomeStile AS VARCHAR(64)) AS NomeStile
	
	, R.Cognome
	, R.Nome
	, R.Sesso
	, R.CodiceFiscale
	, R.DataNascita
	, R.ComuneNascita

	, R.CodiceSanitario

	, R.PrioritaCodice
	, R.PrioritaDescr
	, R.TipoRichiestaCodice
	, R.TipoRichiestaDescr
	, R.Referto
	, R.MedicoRefertanteCodice
	, R.MedicoRefertanteDescr
	
	, R.SpecialitaErogante
	, R.Anteprima
	
	, dbo.GetRefertoOscuramentiXML(R.Id, R.DataPartizione, R.AziendaErogante
					, R.SistemaErogante, R.StrutturaEroganteCodice
					, R.NumeroNosologico, R.RepartoRichiedenteCodice
					, R.RepartoErogante, R.Confidenziale) AS Oscuramenti

FROM 
	[store].[Referti] AS R
WHERE	
	R.StatoRichiestaCodice <> 3	-- Non gli annullati
	--
	-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
	-- 
	AND NOT EXISTS (SELECT * FROM PazientiCancellati  
					WHERE PazientiCancellati.IdPazientiBase = R.IdPaziente
						AND PazientiCancellati.IdRepartiEroganti IS NULL) --toglieremo il campo IdRepartiEroganti dalla tabella PazientiCancellati  
	--
	-- Nascondo gli oscuramenti PUNTUALI
	--
	AND dbo.GetRefertoOscuramentiPuntuali(R.IdEsterno, R.AziendaErogante, R.SistemaErogante
					, R.NumeroNosologico, R.NumeroPrenotazione
					, R.NumeroReferto, R.IdOrderEntry) = 0

