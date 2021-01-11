






CREATE VIEW [ws2].[Referti]
AS
/*
	CREATA DA ETTORE 2015-05-21: AD uso esclusivo dei WS-DWH
		Utilizzo nuove viste nello schema "store"			
		Ho tolto tutti i campi che venivano restituiti per compatibilità e i campi non utilizzati:
			ProvinciaNascita, ComuneResidenza, CodiceSAUB, 
			RuoloVisualizzazioneRepartoRichiedente, RuoloVisualizzazioneSistemaErogante
		Non si filtra più per Cancellato=0 perché lo fa la vista “store”
		Tolto filtro su pazienti cancellati per reparto erogante (non in uso in PROD)
		Aggiunto filtro su OscuramentiPuntuali
		Aggiunto restituzione degli oscuramenti a cui è soggetto il referto dbo.GetRefertoOscuramentiXML()
		Il campo StatoRichiestaCodice lo restituisco come TINYINT
		
	ATTENZIONE:		
	Filtro i pazienti cancellati! Prima non c'era perchè si associava un ruolo di visualizzazione ai cancellati
*/
SELECT  
	ID,
	DataPartizione,
	IdEsterno,
	IdPaziente,
	DataInserimento,
	DataModifica,
	AziendaErogante,
	SistemaErogante,
	RepartoErogante,
	DataReferto,
	DataEvento,
	NumeroReferto,
	NumeroNosologico,
	NumeroPrenotazione,
	IdOrderEntry,
	Firmato,
	RepartoRichiedenteCodice,
	RepartoRichiedenteDescr,
	StatoRichiestaCodice,
	dbo.GetRefertoStatoDesc(RepartoErogante, 
					CONVERT(VARCHAR(16), StatoRichiestaCodice),
					StatoRichiestaDescr
				) AS StatoRichiestaDescr,
	CAST(NomeStile AS VARCHAR(64)) AS NomeStile,	
	
	Cognome,
	Nome,
	Sesso,
	CodiceFiscale,
	DataNascita,
	ComuneNascita,
	CodiceSanitario,
	
	PrioritaCodice,
	PrioritaDescr,
	TipoRichiestaCodice,
	TipoRichiestaDescr,
	Referto,
	MedicoRefertanteCodice,
	MedicoRefertanteDescr,
	SpecialitaErogante,
	Anteprima,
	--
	-- Restituisco XML del referto
	--
	dbo.GetRefertoOscuramentiXML(Id, DataPartizione
					, AziendaErogante, SistemaErogante, StrutturaEroganteCodice
					, NumeroNosologico, RepartoRichiedenteCodice
					, RepartoErogante, Confidenziale) AS Oscuramenti

FROM 
	store.Referti
WHERE
	--ATTENZIONE: nella vista dbo.RefertiWS veniva restituito anche un ruolo di visualizzazione per gli Annullati
	StatoRichiestaCodice <> 3	-- Non gli annullati
	--
	-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
	-- 
	AND NOT EXISTS (SELECT * FROM PazientiCancellati  
					WHERE PazientiCancellati.IdPazientiBase = IdPaziente
						AND PazientiCancellati.IdRepartiEroganti IS NULL) --toglieremo il campo IdRepartiEroganti dalla tabella PazientiCancellati  
	--
	-- Nascondo gli oscuramenti PUNTUALI
	--
	AND dbo.GetRefertoOscuramentiPuntuali(IdEsterno, AziendaErogante, SistemaErogante
					, NumeroNosologico, NumeroPrenotazione
					, NumeroReferto, IdOrderEntry) = 0



