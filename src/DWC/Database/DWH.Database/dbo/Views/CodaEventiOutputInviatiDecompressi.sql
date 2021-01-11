
CREATE VIEW [dbo].[CodaEventiOutputInviatiDecompressi]
AS
SELECT [Id]
      ,[DataInvio]
      ,[IdSequenza]
      ,[DataInserimento]
      ,[IdEvento]
      ,[Operazione]
      ,[IdCorrelazione]
      ,[CorrelazioneTimeout]
      ,[OrdineInvio]
      ,CONVERT(XML,dbo.decompress([MessaggioCompresso])) [Messaggio] 
  FROM [dbo].[CodaEventiOutputInviati]
