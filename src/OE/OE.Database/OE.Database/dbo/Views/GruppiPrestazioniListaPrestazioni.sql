CREATE VIEW [GruppiPrestazioniListaPrestazioni]
AS
  SELECT [GruppiPrestazioni].[ID] AS GruppoPrestazioniID
		,[GruppiPrestazioni].[Descrizione] AS GruppoPrestazioniDescrizione
		,[GruppiPrestazioni].[Preferiti] AS GruppoPrestazioniPreferito
		,[Prestazioni].[Id] AS PrestazioneId
		,[Prestazioni].[Codice] AS PrestazioneCodice
		,[Prestazioni].[CodiceSinonimo] AS PrestazioneCodiceSinonimo
		,[Prestazioni].[Descrizione] AS PrestazioneDescrizione
		,[Prestazioni].[Tipo] AS PrestazioneTipo
		,[Prestazioni].[IDSistemaErogante] AS PrestazioneIDSistemaErogante
		,[Sistemi].[Codice] AS PrestazioneCodiceSistemaErogante
		,[Sistemi].[Descrizione] AS PrestazioneDescrizioneSistemaErogante
		,[Aziende].[Codice] AS PrestazioneCodiceAziendaSistemaErogante
		,[Aziende].[Descrizione] AS PrestazioneDescrizioneAziendaSistemaErogante
  FROM [dbo].[Prestazioni]
		INNER JOIN [dbo].[PrestazioniGruppiPrestazioni]
			ON [Prestazioni].[ID] = [PrestazioniGruppiPrestazioni].[IDPrestazione]
  		INNER JOIN [dbo].[GruppiPrestazioni]
			ON [GruppiPrestazioni].[ID] = [PrestazioniGruppiPrestazioni].[IDGruppoPrestazioni]
  		INNER JOIN [dbo].[Sistemi]
			ON [Sistemi].[ID] = [Prestazioni].[IDSistemaErogante]
  		INNER JOIN [dbo].[Aziende]
			ON [Aziende].[Codice] = [Sistemi].[CodiceAzienda]
