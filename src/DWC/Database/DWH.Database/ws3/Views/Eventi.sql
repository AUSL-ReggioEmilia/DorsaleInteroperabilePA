










CREATE VIEW [ws3].[Eventi]
AS
/*
	CREATA DA ETTORE 2016-03-17: 
		Nuova vista ad uso esclusivo dei WS.DWH-WCF
		Al momento è uguale alla [ws2].[Eventi] tranne che per i seguenti campi che prima mancavano:
			SettoreRicoveroCodice   VARCHAR(16)
			SettoreRicoveroDescr	VARCHAR(128)
			LettoRicoveroCodice		VARCHAR(16)

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

	, E.Diagnosi
	--
	-- Nuovi campi
	--
	,CONVERT(VARCHAR(16), dbo.GetEventiAttributo( E.Id, 'SettoreCodice')) AS SettoreCodice
	,CONVERT(VARCHAR(128), dbo.GetEventiAttributo( E.Id, 'SettoreDescr')) AS SettoreDescr
	,CONVERT(VARCHAR(16), dbo.GetEventiAttributo( E.Id, 'LettoCodice')) AS LettoCodice
	--
	-- Restituisco l'XML con gli oscuramenti bypassabili
	--	
	--, dbo.GetEventoOscuramentiXML(AziendaErogante, NumeroNosologico) AS Oscuramenti

FROM  
	store.Eventi AS E
WHERE	
	--Solo eventi ATTIVI (no annullati ed erased)
	E.StatoCodice = 0
	--Solo eventi che non sono azioni
	AND E.TipoEventoCodice IN ('A','T','D','IL','ML','DL')
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