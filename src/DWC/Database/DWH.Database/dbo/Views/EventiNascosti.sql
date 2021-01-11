



/*
	CREATA SANDRO 2015-02-04: Lista degli eventi OSCURATI sul DWH 
											o CONFIDENZIALI dall'erogante
	MODIFICA ETTORE 2015-03-30: Modificata la funzione per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-04-16: utilizzo della nuova funzione di oscuramento dbo.GetEventiIsOscurato2()	
	MODIFICA SANDRO 2015-09-31: Vista di compatibilità. Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA FUNZIONE OSCURAMENTI
	MODIFICA SANDRO 2016-06-07: Aggiunta FUNZIONE OSCURAMENTI Massivi

	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: non controllo più se la diagnosi contiene HIV/sieropositiv e restituisco Confidenziale=0 sempre

*/
CREATE VIEW [dbo].[EventiNascosti]
AS
	SELECT  
		 Eventi.Id
		,Eventi.DataPartizione
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
		
		--CONFIDENZIALE
		,0 AS Confidenziale,
	
		-- OSCURATO
		CASE WHEN EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK)
						WHERE PazientiCancellati.IdPazientiBase = Eventi.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) THEN 'Paziente'
						
			WHEN dbo.GetEventoOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 1 THEN 'Evento'
			
			WHEN EXISTS (SELECT * FROM dbo.GetEventoOscuramenti(AziendaErogante, NumeroNosologico)) THEN 'Massivo'
		
			ELSE NULL END AS Oscurato

	FROM  [store].[Eventi] AS Eventi  WITH(NOLOCK)

	WHERE	
		-- Oscuramento PUNTUALI
		dbo.GetEventoOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 1

		-- Oscuramento MASSIVI
		OR EXISTS (SELECT * FROM dbo.GetEventoOscuramenti(AziendaErogante, NumeroNosologico))	

		-- Oscuramento PAZIENTE
		OR EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK) 
						WHERE PazientiCancellati.IdPazientiBase = Eventi.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL)
		
		-- Confidenziale
		OR Eventi.Diagnosi LIKE '%HIV%' OR Eventi.Diagnosi LIKE '%sieropositiv%'



GO
GRANT SELECT
    ON OBJECT::[dbo].[EventiNascosti] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[EventiNascosti] TO [DataAccessSql]
    AS [dbo];

