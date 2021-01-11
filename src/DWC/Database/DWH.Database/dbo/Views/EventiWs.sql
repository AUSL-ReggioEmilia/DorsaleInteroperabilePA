

/*
	CREATA DA ETTORE 2015-03-02: Nuova vista dedicata da usare nei webservice
	
	Questa vista è stata creata ad uso delle SP dei WS
	La vista NON FILTRA gli eventi OSCURATI (paziente cancellato): lo fa il codice
	VB dei webservice.
	Restituisce in un unico campo di nome "RuoliVisualizzazione" tutti i ruoli
	di visualizzazione (Es.: "Ruolo1;Ruolo2;..;RuoloN").

	La vista esclude i record oscurati tramite tabella degli Oscuramenti
	
	MODIFICA ETTORE 2015-03-30: Modificata la funzione per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-04-16: utilizzo della nuova funzione di oscuramento dbo.GetEventiIsOscurato2()	
	MODIFICA SANDRO 2015-09-31: Vista di compatibilità. Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA FUNZIONE OSCURAMENTI

*/
CREATE VIEW [dbo].[EventiWs]
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

		,CASE WHEN NOT (
				(Eventi.Diagnosi LIKE '%HIV%') OR 
				(Eventi.Diagnosi LIKE '%sieropositiv%')
				) THEN
			Eventi.Diagnosi
		ELSE
			''	
		END AS Diagnosi
	
		,dbo.GetRuoliVisualizzazioneEventi(Eventi.Id) AS RuoliVisualizzazione
		,Eventi.DataPartizione

	FROM  
		[store].[Eventi] AS Eventi
	WHERE	
		--Solo eventi ATTIVI (no annullati ed erased)
		Eventi.StatoCodice = 0
		--Solo eventi che non sono azioni
		AND Eventi.TipoEventoCodice IN ('A','T','D','IL','ML')
		--
		--
		--
		AND dbo.GetEventoOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 0



GO
GRANT SELECT
    ON OBJECT::[dbo].[EventiWs] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[EventiWs] TO [DataAccessSql]
    AS [dbo];

