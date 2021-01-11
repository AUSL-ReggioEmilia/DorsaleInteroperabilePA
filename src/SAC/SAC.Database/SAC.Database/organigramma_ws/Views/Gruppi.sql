

-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-04
-- Description:	Lista dei Gruppi di AD
-- ================================================
CREATE VIEW [organigramma_ws].[Gruppi]
AS
	SELECT [Id]
		  ,[Utente] AS [Gruppo]
		  ,[Descrizione]
		  ,[Email]
		  ,[Attivo]
	FROM [organigramma].[OggettiActiveDirectory]
	WHERE [Tipo] = 'Gruppo'