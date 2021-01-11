


CREATE VIEW [dbo].[Eventi]
AS
/*
	Tutti gli EVENTI a livello di singlo STORE
	
	NUOVA SANDRO 2015-05-13: Copiata da EventiTutti
*/
	SELECT Id
			,DataPartizione
			,IdEsterno
			,IdPaziente
			,DataInserimento
			,DataModifica
			,AziendaErogante
			,SistemaErogante
			,RepartoErogante
			,DataEvento

			,StatoCodice
			,TipoEventoCodice
			,TipoEventoDescr
			,NumeroNosologico 

			,TipoEpisodio
			,CONVERT(VARCHAR(128), dbo.GetEventiAttributo2(Id, DataPartizione, 'TipoEpisodioDescr')) AS TipoEpisodioDescr

			,CONVERT(VARCHAR(64), dbo.GetEventiAttributo2(Id, DataPartizione, 'Cognome')) AS Cognome
			,CONVERT(VARCHAR(64), dbo.GetEventiAttributo2(Id, DataPartizione, 'Nome')) AS Nome
			,CONVERT(VARCHAR(64), dbo.GetEventiAttributo2(Id, DataPartizione, 'Sesso')) AS Sesso
			,CONVERT(VARCHAR(16), dbo.GetEventiAttributo2(Id, DataPartizione, 'CodiceFiscale')) AS CodiceFiscale
			,dbo.GetEventiAttributo2DateTime(Id, DataPartizione, 'DataNascita') AS DataNascita
			,CONVERT(VARCHAR(64), dbo.GetEventiAttributo2(Id, DataPartizione, 'ComuneNascita')) AS ComuneNascita
			,CONVERT(VARCHAR(64), dbo.GetEventiAttributo2(Id, DataPartizione, 'CodiceSanitario')) AS CodiceSanitario

			,RepartoCodice
			,RepartoDescr

			,Diagnosi

			,dbo.[GetEventiAttributi2Xml](ID, DataPartizione) Attributi

	FROM [dbo].[EventiBase]
