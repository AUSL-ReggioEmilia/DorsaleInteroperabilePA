

CREATE VIEW [dbo].[Ricoveri]
AS
/*
	Tutti gli RICOVERI a livello di singlo STORE, NON i CANCELLATI

	Il campo CANCELLATI sara rimosso in futuro
	
	NUOVA SANDRO 2015-05-13: Copiata da RicoveriTutti
*/
	SELECT Id
			,DataPartizione
			,DataInserimento
			,DataModifica
			,StatoCodice
			,NumeroNosologico
			,AziendaErogante
			,SistemaErogante
			,RepartoErogante
			,IdPaziente
			,OspedaleCodice
			,OspedaleDescr
			,TipoRicoveroCodice
			,TipoRicoveroDescr
			,Diagnosi	
			,DataAccettazione
			,RepartoAccettazioneCodice
			,RepartoAccettazioneDescr

			,DataTrasferimento
			,RepartoCodice
			,RepartoDescr
			,SettoreCodice
			,SettoreDescr
			,LettoCodice
			,DataDimissione

			,CONVERT(VARCHAR(64), dbo.GetRicoveriAttributo2(Id, DataPartizione, 'Cognome')) AS Cognome
			,CONVERT(VARCHAR(64), dbo.GetRicoveriAttributo2(Id, DataPartizione, 'Nome')) AS Nome
			,CONVERT(VARCHAR(1), dbo.GetRicoveriAttributo2(Id, DataPartizione, 'Sesso')) AS Sesso
			,CONVERT(VARCHAR(16), dbo.GetRicoveriAttributo2(Id, DataPartizione, 'CodiceFiscale')) AS CodiceFiscale
			,dbo.GetRicoveriAttributo2DateTime(Id, DataPartizione, 'DataNascita') AS DataNascita
			,CONVERT(VARCHAR(64), dbo.GetRicoveriAttributo2(Id, DataPartizione, 'ComuneNascita')) AS ComuneNascita
			,CONVERT(VARCHAR(64), dbo.GetRicoveriAttributo2(Id, DataPartizione, 'CodiceSanitario')) AS CodiceSanitario

			,dbo.[GetRicoveriAttributi2Xml](ID, DataPartizione) Attributi
		
	FROM dbo.RicoveriBase
	WHERE Cancellato = 0
