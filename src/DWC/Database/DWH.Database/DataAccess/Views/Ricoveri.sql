


CREATE VIEW [DataAccess].[Ricoveri]
AS
/*
	CREATA DA SANDRO 2015-05-22: 
		Ad uso esclusivo per accesso dall'esterno
		Uso la nuova vista store.Ricoveri

	MODIFICATE 2016-10-07 SANDRO: Converto in nVARCHAR perche XML non permette le query distribuite
	MODIFICATA DA ETTORE  2017-11-06: 
		Eliminazione logiche cablate: tolto case che sbiancava la diagnosi nel caso contenesse HIV/sieropositiv
 
*/
	SELECT 
		R.Id
		, R.DataPartizione	
		, R.IdPaziente
		, R.DataInserimento
		, R.DataModifica
		, R.StatoCodice, dbo.GetRicoveriStatiDescrizione(StatoCodice) AS StatoDescrizione
		, R.NumeroNosologico
		, R.AziendaErogante
		, R.SistemaErogante
		, R.RepartoErogante
		, R.OspedaleCodice, R.OspedaleDescr AS OspedaleDescrizione
		, R.TipoRicoveroCodice, R.TipoRicoveroDescr AS TipoRicoveroDescrizione

		, R.Diagnosi
		, R.DataAccettazione
		, R.RepartoAccettazioneCodice, R.RepartoAccettazioneDescr AS RepartoAccettazioneDescrizione

		, R.DataTrasferimento
		, R.RepartoCodice, R.RepartoDescr AS RepartoDescrizione
		, R.SettoreCodice, R.SettoreDescr AS SettoreDescrizione
		, R.LettoCodice
		, R.DataDimissione
		-------------------------------------
		, R.Cognome
		, R.Nome
		, R.Sesso
		, R.CodiceFiscale
		, R.DataNascita
		, R.ComuneNascita
		, R.CodiceSanitario

		-- Aggiungo FLAG calcolati

		, CASE R.StatoCodice WHEN 24 THEN 1
						ELSE 0 END AS Annullato

		, CASE WHEN EXISTS (SELECT * FROM  dbo.GetRicoveroOscuramenti(R.AziendaErogante, R.NumeroNosologico))
				THEN 1 ELSE 0 END AS OscuratoMassivo

		, CASE WHEN dbo.GetRicoveroOscuramentiPuntuali(R.AziendaErogante, R.NumeroNosologico) = 1
				THEN 1 ELSE 0 END AS OscuratoPuntuale
			
		, CASE WHEN EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = R.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) 
						
				THEN 1 ELSE 0 END AS OscuratoPaziente

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		, CONVERT(NVARCHAR(MAX), R.Attributi) AS Attributi
	FROM 
		[store].[Ricoveri] R WITH(NOLOCK)
	WHERE       
		--StatoCodice: 0=Prenotazione,1=Accettazione,2=In reparto,3=Dimissione,4=Riapertura,5=Cancellato
		--StatoCodice: 20=In attesa,21=Chiamato,22=Ricoverato,23=Sospeso,24=Annullato
		R.StatoCodice IN (0,1,2,3,4, 20,21,22,23,24)

