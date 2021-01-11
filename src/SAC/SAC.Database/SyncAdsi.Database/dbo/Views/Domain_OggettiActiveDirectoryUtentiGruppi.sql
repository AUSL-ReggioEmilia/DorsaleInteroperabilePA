-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-09-14
-- Description:	Solo del dominio corrente
-- =============================================
CREATE VIEW [dbo].[Domain_OggettiActiveDirectoryUtentiGruppi] AS

	SELECT [Id]
      ,[IdUtente]
      ,[IdGruppo]
      ,[DataInserimento]
      ,[DataModifica]
      ,[UtenteInserimento]
      ,[UtenteModifica]
	FROM [dbo].[Sac_Organigramma_OggettiActiveDirectoryUtentiGruppi] membri
	WHERE EXISTS (SELECT * FROM [dbo].[Sac_Organigramma_OggettiActiveDirectory] utenti
					WHERE utenti.Id = membri.IdUtente
						AND utenti.Utente LIKE [dbo].[ConfigNetbiosDomainName]() + '\%')

		AND EXISTS (SELECT * FROM [dbo].[Sac_Organigramma_OggettiActiveDirectory] gruppi
					WHERE gruppi.Id = membri.IdGruppo
						AND gruppi.Utente LIKE [dbo].[ConfigNetbiosDomainName]() + '\%')


