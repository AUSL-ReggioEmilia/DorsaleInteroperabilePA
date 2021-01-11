
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[Priorita]
AS
SELECT [Codice]
      ,[Descrizione]
  FROM [dbo].[Priorita] WITH(NOLOCK)
