


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Modify date: 2016-10-10 Aggiunto campo descrizione, usa [dbo].[UnitaOperative]
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[UnitaOperative]
AS
SELECT [ID]
      ,[Codice]
      ,[CodiceAzienda]
	  ,[Attivo]
	  ,[Descrizione]
  FROM [dbo].[UnitaOperative] WITH(NOLOCK)
  WHERE [ID] <> '00000000-0000-0000-0000-000000000000'
