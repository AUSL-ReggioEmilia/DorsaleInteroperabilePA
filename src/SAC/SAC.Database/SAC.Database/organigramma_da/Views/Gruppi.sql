
-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-07-16
-- Modify date: 2014-09-26 - Rinominto Utente in gruppo
-- Modify date: 2016-11-21 - Aggiunto campo Email
-- Description:	Lista dei Gruppi di AD
-- ================================================
CREATE VIEW [organigramma_da].[Gruppi]
AS
	SELECT [Id]
		  ,[Utente] AS [Gruppo]
		  ,[Descrizione]
		  ,[Email]
		  ,[Attivo]
	FROM [organigramma].[OggettiActiveDirectory]
	WHERE [Tipo] = 'Gruppo'
