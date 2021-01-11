
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[ProfiliPrestazioni]
AS
SELECT  p.ID AS [IdProfilo]
		,p.[Codice] AS [ProfiloCodice]
		,p.IDSistemaErogante AS ProfiloIDSistemaErogante
		,s.[CodiceAzienda] + '-' + s.[Codice] AS [ProfiloSistemaErogante]
		,p.[Descrizione] AS [ProfiloDescrizione]
		,CASE p.[Tipo] WHEN 1 THEN 'Profilo blindato'
					WHEN 2 THEN 'Profilo scomponibil'
					WHEN 3 THEN 'Profilo utente'
					ELSE 'NC'
			END AS [ProfiloTipo]

		,p.Attivo AS [ProfiloAttivo]

		,pg.Livello AS [GerarchiaLivello]
		,pg.IdPadre AS [GerarchiaIdPadre]
		,pg.IdFiglio AS [GerarchiaIdFiglio]

		--,pf.ID AS [IdPrestazione]

		,pf.Tipo AS [PrestazioneTipo]
		,pf.[Codice] AS [PrestazioneCodice]

		,p.IDSistemaErogante AS [PrestazioneIDSistemaErogante]
		,pf.[SistemaErogante] AS [PrestazioneSistemaErogante]

		,pf.[Descrizione] AS [PrestazioneDescrizione]
		
  FROM [dbo].[Prestazioni] p WITH(NOLOCK)
	INNER JOIN [dbo].[SistemiEstesa] s WITH(NOLOCK)
		ON p.IDSistemaErogante = s.ID

	CROSS APPLY [dbo].[GetProfiloGerarchia2] (p.ID ) pg

	INNER JOIN [DataConfig].[Prestazioni] pf WITH(NOLOCK)
		ON pf.ID = pg.IDFiglio

  WHERE p.[Tipo] <> 0
