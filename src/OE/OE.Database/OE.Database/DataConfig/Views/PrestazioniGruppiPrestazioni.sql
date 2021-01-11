
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[PrestazioniGruppiPrestazioni]
AS
SELECT 
	 p.[Id] AS IdPrestazione
	,p.[SistemaErogante] AS [PrestazioneSistemaErogante]
	,p.[Codice] AS [PrestazioneCodice]
	,p.[Descrizione] AS [PrestazioneDescrizione]

	,gu.[ID] AS IdGruppo
    ,gu.[Descrizione] AS Gruppo
	 
  FROM [dbo].[GruppiPrestazioni] gu WITH(NOLOCK)

	INNER JOIN [dbo].[PrestazioniGruppiPrestazioni] AS pgp WITH(NOLOCK)
		ON gu.[ID] = pgp.[IDGruppoPrestazioni]

	INNER JOIN [DataConfig].[Prestazioni] AS p WITH(NOLOCK)
		ON pgp.IDPrestazione = p.ID
