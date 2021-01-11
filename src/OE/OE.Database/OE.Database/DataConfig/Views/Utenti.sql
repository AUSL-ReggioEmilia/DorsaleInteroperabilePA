


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Modify date: 2016-10-10 XML ritornato come NVARCHAR(MAX) (no query discribuite)
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[Utenti]
AS
	SELECT u.[ID]
		  ,u.[Utente]
		  ,u.[Descrizione]
		  ,CASE u.[Delega] WHEN 0 THEN 'Non delega'
						 WHEN 1 THEN 'Può delegare'
						 WHEN 2 THEN 'Deve delegare'
				END AS [Delega]

		  ,CASE u.[Tipo] WHEN 0 THEN 'Utente'
					   WHEN 1 THEN 'Gruppo'
				END AS [Tipo]

		  ,CONVERT(NVARCHAR(MAX), (SELECT Gruppo.[ID]
							  , Gruppo.[Descrizione]
							FROM [dbo].[GruppiUtenti] AS Gruppo WITH(NOLOCK)
								INNER JOIN [dbo].[UtentiGruppiUtenti] AS pgp WITH(NOLOCK)
									ON pgp.IDGruppoUtenti = Gruppo.ID
						
							WHERE pgp.[IDUtente] = u.[ID]
							FOR XML AUTO, ROOT('Gruppi')
							)) AS Gruppi

		 ,[Attivo]

	FROM [dbo].[Utenti] u
	WHERE [ID] <> '00000000-0000-0000-0000-000000000000'
