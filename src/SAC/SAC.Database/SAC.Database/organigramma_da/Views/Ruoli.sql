

-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-07-16
-- Description:	Lista dei Ruoli
-- ================================================
CREATE VIEW [organigramma_da].[Ruoli]
AS
	SELECT [ID]
		  ,[Codice]
		  ,[Descrizione]
		  ,[Attivo]
	FROM [organigramma].[Ruoli]
