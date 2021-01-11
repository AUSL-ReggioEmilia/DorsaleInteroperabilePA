
CREATE VIEW [dbo].[Prescrizioni]
AS
/*
	Tutti le PRESCRIZIONI a livello di singlo STORE

	NUOVA SANDRO 2016-08-09
	MODIFICA SANDRO 2016-10-07 Usa la nuova FUNC per attibuti che legge in 1 query
	MODIFICA SANDRO 2016-11-22 La nuova FUNC ha prestazioni peggiori
*/
	SELECT Id, DataPartizione
		, IdEsterno	, IdPaziente
		, DataInserimento, DataModifica, DataModificaEsterno
		, StatoCodice, TipoPrescrizione, DataPrescrizione, NumeroPrescrizione
		, MedicoPrescrittoreCodiceFiscale, QuesitoDiagnostico

		,CONVERT(VARCHAR(64), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'Cognome')) AS Cognome
		,CONVERT(VARCHAR(64), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'Nome')) AS Nome
		,CONVERT(VARCHAR(4), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'Sesso')) AS Sesso
		,CONVERT(VARCHAR(16), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'CodiceFiscale')) AS CodiceFiscale
		,dbo.[GetPrescrizioniAttributo2DateTime](ID, DataPartizione, 'DataNascita') AS DataNascita
		,CONVERT(VARCHAR(64), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'ComuneNascita')) AS ComuneNascita
		,CONVERT(VARCHAR(64), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'CodiceSanitario')) AS CodiceSanitario
		,CONVERT(VARCHAR(64), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'MedicoPrescrittoreCognome')) AS MedicoPrescrittoreCognome
		,CONVERT(VARCHAR(64), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'MedicoPrescrittoreNome')) AS MedicoPrescrittoreNome
		,CONVERT(VARCHAR(64), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'PrioritaCodice')) AS PrioritaCodice
		,CONVERT(VARCHAR(16), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'EsenzioneCodici')) AS EsenzioneCodici
		,CONVERT(VARCHAR(8000), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'Prestazioni')) AS Prestazioni
		,CONVERT(VARCHAR(8000), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'Farmaci')) AS Farmaci
		,CONVERT(VARCHAR(8000), dbo.[GetPrescrizioniAttributo2](ID, DataPartizione, 'PropostaTerapeutica')) AS PropostaTerapeutica

		,dbo.[GetPrescrizioniAttributi2Xml](ID, DataPartizione) Attributi

	FROM [dbo].[PrescrizioniBase]