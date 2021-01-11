

-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-07-16
-- Modify date: 2014-09-10
-- Description:	Lista dei Utenti di AD
-- ================================================
CREATE VIEW [organigramma_da].[Utenti]
AS
	SELECT [Id]
		  ,[Utente]
		  ,[Descrizione]
		  ,[Cognome]
		  ,[Nome]
		  ,[CodiceFiscale]
		  ,[Matricola]
		  ,[Email]
  		  ,[Attivo]
	FROM [organigramma].[OggettiActiveDirectory]
	WHERE [Tipo] = 'Utente'
