


CREATE VIEW [dbo].[Referti]
AS
/*
	Tutti gli REFERTI a livello di singlo STORE, NON i CANCELLATI
		Rimossi: CodiceSAUB, ProvinciaNascita, ComuneResidenza
		Non decodifico StatoRichiestaDesc
		Non converto a varchar StatoRichiestaCodice
	
	Il campo CANCELLATO sarà rimosso in futuro

	NUOVA SANDRO 2015-05-13: Copiata da RefertiTutti
*/
SELECT  ID
		,DataPartizione
		,IdEsterno
		,IdPaziente
		,DataInserimento
		,DataModifica
		,AziendaErogante
		,SistemaErogante
		,RepartoErogante
		,DataReferto
		,DataEvento
		,NumeroReferto
		,NumeroNosologico
		,NumeroPrenotazione
		,IdOrderEntry
		,Firmato

		,RepartoRichiedenteCodice
		,RepartoRichiedenteDescr
		
		,StatoRichiestaCodice AS StatoRichiestaCodice
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'StatoRichiestaDescr')) AS StatoRichiestaDescr	

		,CONVERT(VARCHAR(15), dbo.GetRefertiAttributo2(Id, DataPartizione, 'NomeStile')) AS NomeStile

		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Cognome')) AS Cognome
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Nome')) AS Nome
		,CONVERT(VARCHAR(1), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Sesso')) AS Sesso
		,CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2(Id, DataPartizione, 'CodiceFiscale')) AS CodiceFiscale
		,dbo.GetRefertiAttributo2DateTime(Id, DataPartizione, 'DataNascita') AS DataNascita
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'ComuneNascita')) AS ComuneNascita
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'CodiceSanitario')) AS CodiceSanitario
			
		,CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2(Id, DataPartizione, 'PrioritaCodice')) AS PrioritaCodice
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'PrioritaDescr')) AS PrioritaDescr
		
		,CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2(Id, DataPartizione, 'TipoRichiestaCodice')) AS TipoRichiestaCodice
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'TipoRichiestaDescr')) AS TipoRichiestaDescr
		
		,CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Referto')) AS Referto
		
		,CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2(Id, DataPartizione, 'MedicoRefertanteCodice')) AS MedicoRefertanteCodice
		,CONVERT(VARCHAR(100), dbo.GetRefertiAttributo2(Id, DataPartizione, 'MedicoRefertanteDescr')) AS MedicoRefertanteDescr

		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'SpecialitaErogante')) AS SpecialitaErogante
		,CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2(Id, DataPartizione, 'StrutturaEroganteCodice')) AS StrutturaEroganteCodice

		,CONVERT(BIT, CASE ISNULL(UPPER(
						CONVERT(VARCHAR(4), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Confidenziale'))
											), '')
					WHEN '1' THEN 1
					WHEN 'SI' THEN 1
					WHEN 'TRUE' THEN 1
					WHEN '0' THEN 0
					WHEN 'NO' THEN 0
					WHEN 'FALSE' THEN 0
					WHEN '' THEN 0
					ELSE 1 END) AS Confidenziale

		,CONVERT(VARCHAR(2048), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Anteprima')) AS Anteprima

		,dbo.[GetRefertiAttributi2Xml](ID, DataPartizione) Attributi

FROM [dbo].[RefertiBase]
WHERE Cancellato = 0


