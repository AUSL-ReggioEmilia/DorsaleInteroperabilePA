
CREATE VIEW [dbo].[CodaRefertiOutputInviatiDecompressi]
AS
SELECT [Id]
      ,[DataInvio]
      ,[IdSequenza]
      ,[DataInserimento]
      ,[IdReferto]
      ,[Operazione]
      ,[IdCorrelazione]
      ,[CorrelazioneTimeout]
      ,[OrdineInvio]
      ,CONVERT(XML,dbo.decompress([MessaggioCompresso])) [Messaggio] 
FROM [dbo].[CodaRefertiOutputInviati]
