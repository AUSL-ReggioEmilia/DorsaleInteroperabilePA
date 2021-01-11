



/*
	CREATA SANDRO 2015-02-04: Lista dei ricoveri OSCURATI sul DWH 
											o CONFIDENZIALI dall'erogante
											o CANCELLATI sul DWH 
	MODIFICA ETTORE 2015-03-30: Modificata la funzione per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-04-16: utilizzo della nuova funzione di oscuramento dbo.GetRicoveriIsOscurato2()	
	MODIFICA SANDRO 2015-09-31: Vista di compatibilità. Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA FUNZIONE OSCURAMENTI
	MODIFICA SANDRO 2016-06-07: Aggiunta FUNZIONE OSCURAMENTI Massivi e i cancellati sono negli oscuramenti

	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: non controllo più se la diagnosi contiene HIV/sieropositiv e restituisco Confidenziale=0 sempre
	
*/
CREATE VIEW [dbo].[RicoveriNascosti]
AS
	SELECT Ricoveri.Id
		,Ricoveri.DataInserimento
		,Ricoveri.DataModifica
		,Ricoveri.StatoCodice
		,dbo.GetRicoveriStatiDescrizione(StatoCodice) AS StatoDescr
		,Ricoveri.NumeroNosologico
		,Ricoveri.AziendaErogante
		,Ricoveri.SistemaErogante
		,Ricoveri.RepartoErogante
		,Ricoveri.IdPaziente
		,Ricoveri.OspedaleCodice
		,Ricoveri.OspedaleDescr
		,Ricoveri.TipoRicoveroCodice
		,Ricoveri.TipoRicoveroDescr

		-- CANCELLATO
		,CASE Ricoveri.StatoCodice WHEN 5 THEN 1
								   WHEN 24 THEN 1
						ELSE Ricoveri.Cancellato END AS Cancellato

		--CONFIDENZIALE
		,0 AS Confidenziale,
	
		-- OSCURATO
		CASE 
			-- Oscuramento paziente
			WHEN EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK)
						WHERE PazientiCancellati.IdPazientiBase = Ricoveri.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) THEN 'Paziente'
			
			-- Oscuramento puntuale
			WHEN dbo.GetRicoveroOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 1 THEN 'Ricovero'

			-- Oscuramento massivo
			WHEN EXISTS (SELECT * FROM  dbo.GetRicoveroOscuramenti(AziendaErogante, NumeroNosologico)) THEN 'Massivo'
		
			ELSE NULL END AS Oscurato

	FROM  [store].[RicoveriBase] AS Ricoveri WITH(NOLOCK)

	WHERE
		-- Oscuramento puntuale
		dbo.GetRicoveroOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 1

		-- Oscuramento massivo
		OR EXISTS (SELECT * FROM  dbo.GetRicoveroOscuramenti(AziendaErogante, NumeroNosologico))

		-- Oscuramento paziente
		OR EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK)
						WHERE PazientiCancellati.IdPazientiBase = Ricoveri.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL)	
		-- Confidenziale
		OR Ricoveri.Diagnosi LIKE '%HIV%' OR Diagnosi LIKE '%sieropositiv%'

		-- Cancellato
		OR Ricoveri.StatoCodice = 5
		OR Ricoveri.StatoCodice = 24
		OR Ricoveri.Cancellato = 1


GO
GRANT SELECT
    ON OBJECT::[dbo].[RicoveriNascosti] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[RicoveriNascosti] TO [DataAccessSql]
    AS [dbo];

