
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-02-06
-- Modify date: 2016-10-10 Aggiunto campo descrizione, usa [dbo].[Sistemi]
-- Description:	Accesso alle configirazioni
-- =============================================
CREATE VIEW [DataConfig].[Sistemi]
AS
SELECT [ID]
      ,[Codice]
      ,[CodiceAzienda]
	  ,[Attivo]
      ,[CancellazionePostInoltro]
	  ,[Descrizione]
  FROM [dbo].[Sistemi] WITH(NOLOCK)
  WHERE [ID] <> '00000000-0000-0000-0000-000000000000'
