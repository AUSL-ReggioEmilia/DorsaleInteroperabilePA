

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Modify date: 2016-10-10 XML ritornato come NVARCHAR(MAX) (no query discribuite)
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[Prestazioni]
AS
SELECT  p.ID 
		,p.[Codice] AS [Codice]
		,p.IDSistemaErogante
		,s.[CodiceAzienda] + '-' + s.[Codice] AS [SistemaErogante]

		,p.[CodiceSinonimo] AS [CodiceSinonimo]
		,p.[Descrizione] AS [Descrizione]
		,CASE p.[Tipo] WHEN 0 THEN 'Prestazione'
					WHEN 1 THEN 'Profilo blindato'
					WHEN 2 THEN 'Profilo scomponibil'
					WHEN 3 THEN 'Profilo utente'
					ELSE 'NC'
			END AS [Tipo]

		,CASE p.Provenienza WHEN 0 THEN 'Erogante'
					WHEN 1 THEN 'Richiedente'
					WHEN 2 THEN 'Ws'
					WHEN 3 THEN 'Msg'
					WHEN 4 THEN 'UI'
					ELSE 'NC'
			END AS [Provenienza]

		,p.Attivo

        ,CONVERT(NVARCHAR(MAX), (SELECT Gruppo.[ID]
						  , Gruppo.[Descrizione]
						  , Gruppo.[Preferiti]
						FROM [dbo].[GruppiPrestazioni] AS Gruppo WITH(NOLOCK)
							INNER JOIN [dbo].[PrestazioniGruppiPrestazioni] AS pgp WITH(NOLOCK)
								ON pgp.IDGruppoPrestazioni = Gruppo.ID
						
						WHERE pgp.[IDPrestazione] = p.[ID]
						FOR XML AUTO, ROOT('Gruppi')
						)) AS Gruppi

		,p.DataInserimento
		,p.DataModifica
		,p.UtenteInserimento
		,p.UtenteModifica

  FROM [dbo].[Prestazioni] p WITH(NOLOCK)
	INNER JOIN [dbo].[SistemiEstesa] s WITH(NOLOCK)
		ON p.IDSistemaErogante = s.ID
