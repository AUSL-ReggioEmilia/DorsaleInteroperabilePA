



/*
	MODIFICA ETTORE 2013-06-05: Gestione "Prenotazione" 
		-Gestione della descrizione degli stati per comprendere anche gli stati della "Prenotazione"
		-Aggiunto nuovi stati per la "Prenotazione": 20,21,22,23,24
		-Aggiunto nuovo stato con valore 254="Stato Sconosciuto": aggiunto nel filtro where
		-Ora si usa tabella d3egli stati + function per determinare la descrizione associata allo stato
		
	MODIFICA ETTORE 2014-10-13: aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-03-30: Modificata la funzione per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-04-16: utilizzo della nuova funzione di oscuramento dbo.GetRicoveriIsOscurato2()	
	MODIFICA ETTORE 2015-05-04: utilizzo della nuova function per leggere gli attributi che usano la data di partizione
	MODIFICA SANDRO 2015-09-31: Vista di compatibilità. Accede tramite lo schema STORE
	MODIFICA STEFANO 2015-09-23: SOSTITUITA FUNZIONE OSCURAMENTI
	MODIFICATA DA ETTORE  2017-11-06: Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv
*/
CREATE VIEW [dbo].[Ricoveri]
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

		,Ricoveri.Diagnosi

		,Ricoveri.DataAccettazione
		,Ricoveri.RepartoAccettazioneCodice
		,Ricoveri.RepartoAccettazioneDescr

		,Ricoveri.DataTrasferimento
		,Ricoveri.RepartoCodice
		,Ricoveri.RepartoDescr
		,Ricoveri.SettoreCodice
		,Ricoveri.SettoreDescr
		,Ricoveri.LettoCodice
		,Ricoveri.DataDimissione
		-------------------------------------
		,Ricoveri.Cognome
		,Ricoveri.Nome
		--,Ricoveri.Sesso
		,Ricoveri.CodiceFiscale
		,Ricoveri.DataNascita
		,Ricoveri.ComuneNascita
		,Ricoveri.CodiceSanitario
		--
		-- Ruolo di visualizzazione per SistemaErogante:
		-- è il ruolo di visualizzazione che si ottiene dal primo record di accettazione
		,dbo.GetRuoloVisualizzazioneRicoveriSistemaErogante2(Ricoveri.AziendaErogante, Ricoveri.SistemaErogante) AS RuoloVisualizzazioneSistemaErogante
		--
		-- Ruolo di visualizzazione per RepartoRicovero
		-- è il ruolo di visualizzazione che si ottiene dal primo record di accettazione
		,dbo.GetRuoloVisualizzazioneRicoveriRepartoRicovero2(Ricoveri.AziendaErogante, Ricoveri.SistemaErogante
																			, Ricoveri.RepartoAccettazioneCodice) AS RuoloVisualizzazioneRepartoRicovero

	FROM 
		[store].[Ricoveri] AS Ricoveri
	WHERE       
		--StatoCodice: 0=Prenotazione,1=Accettazione,2=In reparto,3=Dimissione,4=Riapertura,5=Cancellato
		--StatoCodice: 20=In attesa,21=Chiamato,22=Ricoverato,23=Sospeso,24=Annullato
		Ricoveri.StatoCodice IN (0,1,2,3,4, 20,21,22,23,24)

		--Nelle viste STORE sno già filtrati per cancellato
		--AND Ricoveri.Cancellato = 0
		--
		-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
		-- MODIFICA ETTORE: 2012-10-31
		AND NOT EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = Ricoveri.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL)	
		--
		-- Filtro per oscuramenti puntuali
		--
		AND dbo.GetRicoveroOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 0



GO
GRANT SELECT
    ON OBJECT::[dbo].[Ricoveri] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Ricoveri] TO [DataAccessSql]
    AS [dbo];

