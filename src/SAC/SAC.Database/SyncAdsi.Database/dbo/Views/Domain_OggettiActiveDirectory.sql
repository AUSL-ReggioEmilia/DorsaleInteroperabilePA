
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-09-14
-- Description:	Solo del dominio corrente
-- =============================================
CREATE VIEW [dbo].[Domain_OggettiActiveDirectory] AS

	SELECT [Id]
      ,[Utente]
      ,[Tipo]
      ,[Descrizione]
      ,[Cognome]
      ,[Nome]
      ,[CodiceFiscale]
      ,[Matricola]
      ,[Email]
      ,[Attivo]
      ,[DataInserimento]
      ,[DataModifica]
      ,[UtenteInserimento]
      ,[UtenteModifica]
      ,[DataModificaEsterna]
	FROM [dbo].[Sac_Organigramma_OggettiActiveDirectory]
	WHERE Utente LIKE [dbo].[ConfigNetbiosDomainName]() + '\%'

