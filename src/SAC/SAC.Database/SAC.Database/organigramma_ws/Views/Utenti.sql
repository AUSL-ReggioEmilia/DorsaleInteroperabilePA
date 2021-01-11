-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Lista degli Utenti di AD
-- ================================================
CREATE VIEW [organigramma_ws].[Utenti]
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