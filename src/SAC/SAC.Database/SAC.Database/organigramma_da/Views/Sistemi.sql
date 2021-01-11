


-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-12
-- Description:	Lista dei SistemiEroganti
-- ================================================
CREATE VIEW [organigramma_da].[Sistemi]
AS
	SELECT [ID]
		  ,[Codice]
		  ,[CodiceAzienda] AS Azienda
		  ,[Descrizione]
		  ,[Richiedente]
		  ,[Erogante]
		  ,[Attivo]
	FROM [organigramma].[Sistemi]

