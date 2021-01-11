

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Modify date: 2016-10-10 XML ritornato come NVARCHAR(MAX) (no query discribuite)
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[GruppiUtenti]
AS
SELECT gu.[ID]
      ,gu.[Descrizione]
      ,CONVERT(NVARCHAR(MAX), (SELECT Utente.Id
						  , Utente.Utente
						  , Utente.Descrizione
						FROM [dbo].[Utenti] AS Utente WITH(NOLOCK)
							INNER JOIN [dbo].[UtentiGruppiUtenti] AS ugu WITH(NOLOCK)
								ON ugu.IDUtente = Utente.ID
						
						WHERE ugu.[IDGruppoUtenti] = gu.[ID]
						FOR XML AUTO, ROOT('Utenti')
						)) AS Utenti

  FROM [dbo].[GruppiUtenti] gu WITH(NOLOCK)

