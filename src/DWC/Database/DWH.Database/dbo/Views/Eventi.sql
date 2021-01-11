



/*
	MODIFICA ETTORE 2014-10-13: aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-04-16: utilizzo della nuova funzione di oscuramento dbo.GetEventiIsOscurato2()
	MODIFICA SANDRO 2015-09-31: Vista di compatibilità. Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA FUNZIONE OSCURAMENTI
	MODIFICATA DA ETTORE  2017-11-06: Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv
*/
CREATE VIEW [dbo].[Eventi]
AS
	SELECT  
		Eventi.Id
		,Eventi.IdEsterno
		,Eventi.IdPaziente
		,Eventi.DataInserimento
		,Eventi.DataModifica
		,Eventi.AziendaErogante
		,Eventi.SistemaErogante
		,Eventi.RepartoErogante
		,Eventi.DataEvento

		,Eventi.StatoCodice
		,Eventi.TipoEventoCodice
		,Eventi.TipoEventoDescr
		,Eventi.NumeroNosologico 

		,Eventi.TipoEpisodio
		,Eventi.TipoEpisodioDescr

		,Eventi.Cognome
		,Eventi.Nome
		,Eventi.CodiceFiscale
		,Eventi.DataNascita
		,Eventi.ComuneNascita
		,Eventi.CodiceSanitario

		,Eventi.RepartoCodice
		,Eventi.RepartoDescr

		,Eventi.Diagnosi
	
		,dbo.GetRuoloVisualizzazioneEventiReparto(
				Eventi.AziendaErogante,
				Eventi.SistemaErogante,
				Eventi.RepartoCodice) AS RuoloVisualizzazioneReparto

		,dbo.GetRuoloVisualizzazioneEventiSistemaErogante(
				Eventi.AziendaErogante,
				Eventi.SistemaErogante) AS RuoloVisualizzazioneSistemaErogante

	FROM  [store].[Eventi] AS Eventi

	WHERE	
		--Solo eventi ATTIVI (no annullati ed erased)
		Eventi.StatoCodice = 0
		--Solo eventi che non sono azioni
		AND Eventi.TipoEventoCodice IN ('A','T','D','IL','ML')
		--
		-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
		-- MODIFICA ETTORE: 2012-10-31
		AND NOT EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = Eventi.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL)	
		--
		--
		--
		AND dbo.GetEventoOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 0



GO
GRANT SELECT
    ON OBJECT::[dbo].[Eventi] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Eventi] TO [DataAccessSql]
    AS [dbo];

