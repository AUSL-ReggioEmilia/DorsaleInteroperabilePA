


CREATE VIEW [DataAccess].[Eventi]
AS
/*
	CREATA DA SANDRO 2015-05-22: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.Eventi
	
	MODIFICATA DA SANDRO 2016-06-07:
		Rimosso filtro E.StatoCodice = 0

	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv
*/
	SELECT  
		E.Id
		, E.DataPartizione
		, E.IdEsterno
		, E.IdPaziente
		, E.DataInserimento
		, E.DataModifica
		, E.AziendaErogante
		, E.SistemaErogante
		, E.RepartoErogante
		, E.DataEvento
		, E.StatoCodice
		, E.TipoEventoCodice, E.TipoEventoDescr AS TipoEventoDescrizione
		, E.NumeroNosologico 
		, E.TipoEpisodio, E.TipoEpisodioDescr AS TipoEpisodioDescrizione

		, E.Cognome
		, E.Nome
		, E.Sesso
		, E.CodiceFiscale
		, E.DataNascita
		, E.ComuneNascita
		, E.CodiceSanitario
		
		, E.RepartoCodice, E.RepartoDescr AS RepartoDescrizione
		
		, E.Diagnosi
		
		-- Aggiungo FLAG calcolati

		, CASE WHEN E.StatoCodice = 0
				THEN 0 ELSE 1 END AS Annullato

		, CASE WHEN EXISTS (SELECT * FROM  dbo.GetEventoOscuramenti(E.AziendaErogante, E.NumeroNosologico))
				THEN 1 ELSE 0 END AS OscuratoMassivo

		, CASE WHEN dbo.GetEventoOscuramentiPuntuali(E.AziendaErogante, E.NumeroNosologico) = 1
				THEN 1 ELSE 0 END AS OscuratoPuntuale
			
		, CASE WHEN EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = E.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) 
						
				THEN 1 ELSE 0 END AS OscuratoPaziente

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		, CONVERT(NVARCHAR(MAX), E.Attributi) AS Attributi

	FROM  [store].[Eventi] E  WITH(NOLOCK)

	WHERE	
		--Solo eventi che non sono azioni
		 E.TipoEventoCodice IN ('A','T','D','IL','ML', 'DL')

		--Solo eventi ATTIVI (no annullati ed erased)
		--SANDRO 2016-06-07
		--AND E.StatoCodice = 0
