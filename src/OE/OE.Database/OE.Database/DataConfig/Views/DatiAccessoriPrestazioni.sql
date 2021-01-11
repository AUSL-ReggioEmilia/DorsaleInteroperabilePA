
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[DatiAccessoriPrestazioni]
AS
SELECT dap.[ID]
      ,dap.[CodiceDatoAccessorio]
      ,p.[Codice] AS [PrestazioneCodice]

      ,p.IDSistemaErogante
      ,s.[CodiceAzienda] + '-' + s.[Codice] AS [SistemaErogante]

      ,p.[CodiceSinonimo] AS [PrestazioneCodiceSinonimo]
      ,p.[Descrizione] AS [PrestazioneDescrizione]
      ,CASE p.[Tipo] WHEN 0 THEN 'Prestazione'
					WHEN 1 THEN 'Profilo blindato'
					WHEN 2 THEN 'Profilo scomponibil'
					WHEN 3 THEN 'Profilo utente'
					ELSE 'NC'
			END AS [PrestazioneTipo]
      ,dap.[Attivo]
      ,ISNULL(dap.[Sistema], 0) AS [TipoSistema]
      ,dap.[ValoreDefault]
  FROM [dbo].[DatiAccessoriPrestazioni] dap WITH( NOLOCK)
	INNER JOIN [dbo].[Prestazioni] p WITH(NOLOCK)
		ON dap.[IDPrestazione] = p.ID
	INNER JOIN [dbo].[SistemiEstesa] s WITH(NOLOCK)
		ON p.IDSistemaErogante = s.ID

