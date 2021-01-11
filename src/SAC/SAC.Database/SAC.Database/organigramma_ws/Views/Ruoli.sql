


-- ================================================
-- Author:		ETTORE GARULLI
-- Create date: 2019-04-01
-- Description:	Lista dei Ruoli 
--				Mutuata dalla [organigramma_da].[Ruoli]
-- ================================================
CREATE VIEW [organigramma_ws].[Ruoli]
AS
	SELECT [ID]
		  ,[Codice]
		  ,[Descrizione]
		  ,[Attivo]
	FROM [organigramma].[Ruoli]