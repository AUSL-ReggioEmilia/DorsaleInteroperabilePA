






CREATE VIEW [ws3].[Ricoveri]
AS
/*
	CREATA DA ETTORE 2016-03-17: Nuova vista dedicata da usare nei webservice WS-DWH-WCF
	Gestione "Prenotazione" 
		-Gestione della descrizione degli stati per comprendere anche gli stati della "Prenotazione"
	La vista esclude i record oscurati tramite tabella degli Oscuramenti

	MODIFICA ETTORE 2016-10-17: restituzione del campo StatoCodice e StatoDescrizione (che sostituisce il campo Stato)
	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv
*/
SELECT 
	Id
	--
	-- NUOVO: Discrimina se ricovero o lista di attesa
	--
	, CASE WHEN StatoCodice IN (20,21,22,23,24) THEN
	   CAST('Prenotazione' AS VARCHAR(16))
	 ELSE
		CAST('Ricovero' AS VARCHAR(16))
	END AS Categoria
	-- 
	-- Descrizione dell'ultimo evento: 
	-- se "ricovero":		Accettazione, Trasferimento, Dimissione, Riapertura 
	-- se "prenotazione":	Apertura, Chiusura
	--
	, StatoCodice	--Codice dello stato del ricovero
	, CASE 
		WHEN StatoCodice IN (0,1,2,3,4) THEN
			CASE WHEN StatoCodice = 2 THEN
				CAST('Trasferimento' AS VARCHAR(64))
			ELSE
				CAST(ISNULL(dbo.GetRicoveriStatiDescrizione(StatoCodice),'') AS VARCHAR(64))
			END
		WHEN StatoCodice IN (20,21,23) THEN --Prenotazione Aperta
			CAST('Apertura' AS VARCHAR(64))
		WHEN StatoCodice IN (22,24) THEN --Prenotazione Chiusa
			CAST('Chiusura' AS VARCHAR(64))
		ELSE
			CAST('' AS VARCHAR(64))
		END AS StatoDescrizione --Descrizione dello stato del ricovero. Prima si chiamava UltimoEventoDescr	
	----------------------------------------------------------------		
	,DataPartizione
	,DataInserimento
	,DataModifica
	,NumeroNosologico
	,AziendaErogante
	,SistemaErogante
	,RepartoErogante
	,IdPaziente
	,OspedaleCodice
	,OspedaleDescr
	,ISNULL(TipoRicoveroCodice, '') AS TipoRicoveroCodice
	,ISNULL(TipoRicoveroDescr,'') AS TipoRicoveroDescr
	--
	-- Diagnosi
	--
	,Diagnosi	
	,DataAccettazione
	,RepartoAccettazioneCodice
	,RepartoAccettazioneDescr
	-----------------------------
	--Reparto corrente: serve da usare come filtro sul reparto corrente
	,RepartoCodice
	,RepartoDescr	
	,DataTrasferimento
	-----------------------------
	,SettoreCodice
	,SettoreDescr
	,LettoCodice
	,DataDimissione
	-------------------------------------
	--RepartoCorrenteCodice e RepartoCorrenteDescr: se Dimissione restituisce ''
	, CASE WHEN DataDimissione IS NULL THEN
		CAST(ISNULL(RepartoCodice,'') AS VARCHAR(16))
	  ELSE
		CAST('' AS VARCHAR(16))
	  END AS RepartoCorrenteCodice
	, CASE WHEN DataDimissione IS NULL THEN
		CAST(ISNULL(RepartoDescr, '') AS VARCHAR(128))
	  ELSE
		CAST('' AS VARCHAR(128))
	  END AS RepartoCorrenteDescr
	--
	-- RepartoDimissioneCodice, RepartoDimissioneDescr
	-- Li restituisco solo se il ricovero è in dimissione
	--
	, CASE WHEN NOT DataDimissione IS NULL THEN
		RepartoCodice
	ELSE
		CAST(NULL AS VARCHAR(16))
	END AS RepartoDimissioneCodice
	, CASE WHEN NOT DataDimissione IS NULL THEN
		RepartoDescr
	ELSE
		CAST(NULL AS VARCHAR(128))
	END AS RepartoDimissioneDescr	  
	--NUOVO
	, CONVERT(VARCHAR(64), dbo.GetRicoveriAttributo2( Ricoveri.Id, Ricoveri.DataPartizione,  'NumEpisodioOriginePS')) AS NumeroNosologicoOrigine
	,Cognome
	,Nome
	,Sesso
	,CodiceFiscale
	,DataNascita
	,ComuneNascita
	,CodiceSanitario

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