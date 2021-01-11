CREATE VIEW [sole].[CodaEventiRimossiDecompressi] AS
SELECT [Id]
      ,[DataRimozione]
      ,CONVERT(XML, dbo.decompress([Record])) [Record]
      ,[IdEvento]
      ,[Motivo]
FROM [sole].[CodaEventiRimossi]