
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[DatiAccessoriSistema]
AS
SELECT das.[ID]
      ,das.[CodiceDatoAccessorio]

      ,das.[IDSistema] AS [IDSistemaErogante]
      ,s.[CodiceAzienda] + '-' + s.[Codice] AS [SistemaErogante]

      ,das.[Attivo]
      ,ISNULL(das.[Sistema], 0) AS [TipoSistema]
      ,das.[ValoreDefault]
  FROM [dbo].[DatiAccessoriSistemi] das WITH(NOLOCK)
	INNER JOIN [dbo].[SistemiEstesa] s WITH(NOLOCK)
		ON das.IDSistema = s.ID
