
-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-12
-- Description:	Lista delle Azienda
-- ================================================
CREATE VIEW [organigramma_da].[Aziende]
AS
	SELECT [Codice]
		  ,[Descrizione]
	FROM [organigramma].[Aziende]
