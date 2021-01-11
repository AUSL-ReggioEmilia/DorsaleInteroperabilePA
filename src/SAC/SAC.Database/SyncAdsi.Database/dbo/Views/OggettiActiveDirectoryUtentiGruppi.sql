-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-09-14
-- Description:	Vista su sinonimo del SAC
-- =============================================
CREATE VIEW [dbo].[OggettiActiveDirectoryUtentiGruppi] AS

	SELECT [Id]
      ,[IdUtente]
      ,[IdGruppo]
      ,[DataInserimento]
      ,[DataModifica]
      ,[UtenteInserimento]
      ,[UtenteModifica]
	FROM [dbo].[Sac_Organigramma_OggettiActiveDirectoryUtentiGruppi] membri
