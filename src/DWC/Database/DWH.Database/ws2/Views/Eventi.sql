







CREATE VIEW [ws2].[Eventi]
AS
/*
	CREATA DA ETTORE 2015-05-22: 
		Nuova vista ad uso esclusivo dei WS2 (WEB-SERVICE-DWH)
		Utilizzo nuova vista store.Eventi
		Non uso più le funzioni GetAttributo()
		Restituisco la DataPartizione, il campo Sesso, il nuovo campo Oscuramenti
		Tolto i campi RuoloVisualizzazioneXXX
	ATTENZIONE:		
	Filtro i pazienti cancellati! Prima non c'era perchè si associava un ruolo di visualizzazione ai cancellati

	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv
*/
SELECT  
	E.Id
	,E.DataPartizione
	,E.IdEsterno
	,E.IdPaziente
	,E.DataInserimento
	,E.DataModifica
	,E.AziendaErogante
	,E.SistemaErogante
	,E.RepartoErogante
	,E.DataEvento

	,E.StatoCodice
	,E.TipoEventoCodice
	,E.TipoEventoDescr
	,E.NumeroNosologico 

	,E.TipoEpisodio
	,E.TipoEpisodioDescr
	,E.Cognome
	,E.Nome
	,E.CodiceFiscale
	,E.DataNascita
	,E.ComuneNascita
	,E.CodiceSanitario

	,E.RepartoCodice
	,E.RepartoDescr

	,E.Diagnosi
	--
	-- Restituisco l'XML con gli oscuramenti bypassabili
	--	
	, dbo.GetEventoOscuramentiXML(AziendaErogante, NumeroNosologico) AS Oscuramenti

FROM  
	store.Eventi AS E
WHERE	
	--Solo eventi ATTIVI (no annullati ed erased)
	E.StatoCodice = 0
	--Solo eventi che non sono azioni
	AND E.TipoEventoCodice IN ('A','T','D','IL','ML')
	--
	-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
	-- 
	AND NOT EXISTS (SELECT * FROM PazientiCancellati  
					WHERE PazientiCancellati.IdPazientiBase = E.IdPaziente
						AND PazientiCancellati.IdRepartiEroganti IS NULL) --toglieremo il campo IdRepartiEroganti dalla tabella PazientiCancellati  
	--
	-- Filtro gli oscuramenti puntuali
	--
	AND dbo.GetEventoOscuramentiPuntuali(E.AziendaErogante, E.NumeroNosologico) = 0



