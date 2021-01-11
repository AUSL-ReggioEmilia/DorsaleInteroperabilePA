
CREATE VIEW [dbo].[CodaPrescrizioniOutputInviatiDecompressi]
AS
SELECT [Id]
      ,[DataInvio]
      ,[IdSequenza]
      ,[DataInserimento]
      ,[IdPrescrizione]
      ,[Operazione]
      ,[IdCorrelazione]
      ,[CorrelazioneTimeout]
      ,[OrdineInvio]
      ,CONVERT(XML,dbo.decompress([MessaggioCompresso])) [Messaggio] 
FROM [dbo].[CodaPrescrizioniOutputInviati]