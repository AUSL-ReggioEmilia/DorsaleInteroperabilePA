










CREATE VIEW [frontend].[Eventi]
AS
/*
	CREATA DA ETTORE 2015-05-22: 
		Nuova vista ad uso esclusivo del front end web
		Utilizzo nuova vista store.Eventi
		Tolto il filtro Cancellato=0, lo fa la vista store.Ricoveri
		Non uso più le funzioni GetAttributo()
		Restituisco la DataPartizione, il campo Sesso, il nuovo campo Oscuramenti
		Tolto i campi RuoloVisualizzazioneXXX
	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv
*/
SELECT  
	Id
	, DataPartizione
	, IdEsterno
	, IdPaziente
	, DataInserimento
	, DataModifica
	, AziendaErogante
	, SistemaErogante
	, RepartoErogante
	, DataEvento
	, StatoCodice
	, TipoEventoCodice
	, TipoEventoDescr
	, NumeroNosologico 
	, TipoEpisodio
	, TipoEpisodioDescr

	, Cognome
	, Nome
	, Sesso
	, CodiceFiscale
	, DataNascita
	, ComuneNascita
	, CodiceSanitario
	, RepartoCodice
	, RepartoDescr
	, Diagnosi 
	--
	-- Restituisco l'XML con gli oscuramenti bypassabili
	--	
	, dbo.GetEventoOscuramentiXML(AziendaErogante, NumeroNosologico) AS Oscuramenti

FROM  
	store.Eventi
WHERE	
	--Solo eventi ATTIVI (no annullati ed erased)
	StatoCodice = 0
	--Solo eventi che non sono azioni
	AND TipoEventoCodice IN ('A','T','D','IL','ML')
	--
	-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
	-- 
	AND NOT EXISTS (SELECT * FROM PazientiCancellati  
					WHERE PazientiCancellati.IdPazientiBase = IdPaziente
						AND PazientiCancellati.IdRepartiEroganti IS NULL)  --toglieremo il campo IdRepartiEroganti dalla tabella PazientiCancellati  
	--
	--
	--
	AND dbo.GetEventoOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 0



