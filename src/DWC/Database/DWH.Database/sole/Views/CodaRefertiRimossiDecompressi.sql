
CREATE VIEW [sole].[CodaRefertiRimossiDecompressi] AS
SELECT [Id]
      ,[DataRimozione]
      ,CONVERT(XML, dbo.decompress([Record])) [Record]
      ,[IdReferto]
      ,[Motivo]
FROM [sole].[CodaRefertiRimossi]