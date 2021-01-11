





CREATE VIEW [frontend].[Ricoveri]
AS
/*
	CREATA DA ETTORE 2015-05-22: 
		Uso la nuova vista store.Ricoveri 
		Tolto il filtro Cancellato=0, lo fa la vista store.Ricoveri
		Non uso più le funzioni GetAttributo()
		Restituisco la DataPartizione, il campo Sesso, il nuovo campo Oscuramenti
		Rimosso i campi RuoliVisualizzazioneXXX

	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv

*/
SELECT 
	Id
    , DataPartizione	
	, DataInserimento
	, DataModifica
	, StatoCodice
	, dbo.GetRicoveriStatiDescrizione(StatoCodice) AS StatoDescr
	, NumeroNosologico
	, AziendaErogante
	, SistemaErogante
	, RepartoErogante
	, IdPaziente
	, OspedaleCodice
	, OspedaleDescr
	, TipoRicoveroCodice
	, TipoRicoveroDescr
	, Diagnosi
	, DataAccettazione
	, RepartoAccettazioneCodice
	, RepartoAccettazioneDescr

	, DataTrasferimento
	, RepartoCodice
	, RepartoDescr
	, SettoreCodice
	, SettoreDescr
	, LettoCodice
	, DataDimissione
	-------------------------------------
	, Cognome
	, Nome
	, Sesso
	, CodiceFiscale
	, DataNascita
	, ComuneNascita
	, CodiceSanitario
	--
	-- Restituisco XML con gli abbonamenti Bypassabili
	--
    , dbo.GetRicoveroOscuramentiXml(AziendaErogante, NumeroNosologico) AS Oscuramenti

FROM 
	store.Ricoveri
WHERE       
	--StatoCodice: 0=Prenotazione,1=Accettazione,2=In reparto,3=Dimissione,4=Riapertura,5=Cancellato
	--StatoCodice: 20=In attesa,21=Chiamato,22=Ricoverato,23=Sospeso,24=Annullato
	StatoCodice IN (0,1,2,3,4, 20,21,22,23,24)
	--
	-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
	-- 
	AND NOT EXISTS (SELECT * FROM PazientiCancellati  
					WHERE PazientiCancellati.IdPazientiBase = IdPaziente
						AND PazientiCancellati.IdRepartiEroganti IS NULL)	 --toglieremo il campo IdRepartiEroganti dalla tabella PazientiCancellati  
	--
	-- Filtro per oscuramenti puntuali
	--
	AND dbo.GetRicoveroOscuramentiPuntuali(AziendaErogante, NumeroNosologico) = 0



