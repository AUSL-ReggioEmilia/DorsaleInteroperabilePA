

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Modify date: 2016-10-10 XML ritornato come NVARCHAR(MAX) (no query discribuite)
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[GruppiPrestazioni]
AS
SELECT gp.[ID]
      ,gp.[Descrizione]
      ,gp.[Preferiti]

      ,CONVERT(NVARCHAR(MAX), (SELECT Prestazione.Codice
						  , Prestazione.IdSistemaErogante
						  , s.[CodiceAzienda] + '-' + s.[Codice] AS [SistemaErogante]
						  , Prestazione.CodiceSinonimo
						  , Prestazione.Descrizione

						FROM [dbo].[Prestazioni] Prestazione WITH(NOLOCK)
							INNER JOIN [dbo].[SistemiEstesa] s WITH(NOLOCK)
								ON Prestazione.IDSistemaErogante = s.ID

							INNER JOIN [dbo].[PrestazioniGruppiPrestazioni] AS pgp WITH(NOLOCK)
								ON pgp.IDPrestazione = Prestazione.ID
						
						WHERE pgp.[IDGruppoPrestazioni] = gp.[ID]
						FOR XML AUTO, ROOT('Prestazioni')
						)) AS Prestazioni

  FROM [dbo].[GruppiPrestazioni] gp WITH(NOLOCK)

