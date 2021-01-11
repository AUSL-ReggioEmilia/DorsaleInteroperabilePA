
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[Regimi]
AS
SELECT [Codice]
      ,[Descrizione]
  FROM [dbo].[Regimi] WITH(NOLOCK)
