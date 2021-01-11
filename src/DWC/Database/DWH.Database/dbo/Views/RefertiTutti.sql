


/*
	Questa vista è stata creata ad uso delle SP dei WS2 e del FRONT-END
	La vista NON FILTRA i referti OSCURATI (Cancellato=1, paziente cancellato),
	ANNULLATI, CONFIDENZIALI: lo fa il codice VB dei webservice
	Restituisce in un unico campo di nome "RuoliVisualizzazione" tutti i ruoli
	di visualizzazione (Es.: "Ruolo1;Ruolo2;..;RuoloN").
	
	MODIFICA ETTORE 2014-05-30: aggiunti i nuovi campi DataEvento,Firmato
	MODIFICA ETTORE 2014-10-13: aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-03-03: uso delle function GetRefertiAttributo2() e GetRefertiAttributo2DateTime() + nuovo filtro oscuramento

	MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA CHIAMATA A FUNCTION OSCURAMENTI
*/
CREATE VIEW [dbo].[RefertiTutti]
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

		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'Cognome')) AS Cognome,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'Nome')) AS Nome,
		CONVERT(VARCHAR(1), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'Sesso')) AS Sesso,
		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'CodiceFiscale')) AS CodiceFiscale,
		dbo.GetRefertiAttributo2DateTime( Referti.Id, Referti.DataPartizione, 'DataNascita') AS DataNascita,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'ComuneNascita')) AS ComuneNascita,
		CONVERT(VARCHAR(4), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'ProvinciaNascita')) AS ProvinciaNascita,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'ComuneResidenza')) AS ComuneResidenza,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'CodiceSAUB')) AS CodiceSAUB,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione,'CodiceSanitario')) AS CodiceSanitario,

		CONVERT(VARCHAR(15), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'NomeStile')) AS NomeStile,
	
		Referti.RepartoRichiedenteCodice,
		Referti.RepartoRichiedenteDescr,

		CONVERT(VARCHAR(16), Referti.StatoRichiestaCodice) AS StatoRichiestaCodice,
	
		dbo.GetRefertoStatoDesc(Referti.RepartoErogante, 
						CONVERT(VARCHAR(16), Referti.StatoRichiestaCodice),
						CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'StatoRichiestaDescr')) 
					) AS StatoRichiestaDescr,

		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'PrioritaCodice')) AS PrioritaCodice,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'PrioritaDescr')) AS PrioritaDescr,

		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'TipoRichiestaCodice')) AS TipoRichiestaCodice,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'TipoRichiestaDescr')) AS TipoRichiestaDescr,

		CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'Referto')) AS Referto,

		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'MedicoRefertanteCodice')) AS MedicoRefertanteCodice,
		CONVERT(VARCHAR(100), dbo.GetRefertiAttributo2( Referti.Id, Referti.DataPartizione, 'MedicoRefertanteDescr')) AS MedicoRefertanteDescr,
		--
		-- Restituisco il campo di stato Cancellato
		--
		Referti.Cancellato,
		--
		-- Restituisco l'IdOrderEntry
		--
		Referti.IdOrderEntry,
		--
		-- Restituisce elenco dei ruoli di visualizzazione
		--	
		dbo.GetRuoliVisualizzazioneReferti(Referti.Id) AS RuoliVisualizzazione,
		Referti.DataPartizione,
	
		Referti.DataEvento,
		Referti.Firmato

	FROM 
		[store].[RefertiBase] AS Referti
	WHERE
		 dbo.GetRefertoOscuramentiPuntuali(Referti.IdEsterno 
									, Referti.AziendaErogante
									, Referti.SistemaErogante
									, Referti.NumeroNosologico 
									, Referti.NumeroPrenotazione
									, Referti.NumeroReferto
									, Referti.IdOrderEntry	) = 0




GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiTutti] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiTutti] TO [ExecuteFrontEnd]
    AS [dbo];

