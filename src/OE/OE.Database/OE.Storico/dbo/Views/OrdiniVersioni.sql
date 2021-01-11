CREATE VIEW [dbo].[OrdiniVersioni]
AS 
SELECT [ID]
      ,[DataInserimento]
      ,[IDTicketInserimento]
      ,[IDOrdineTestata]
      ,[Tipo]
      ,[StatoOrderEntry]
      ,CASE WHEN StatoCompressione = 2 THEN CAST(dbo.decompress([DatiVersioneXmlCompresso]) AS XML)
			ELSE [DatiVersione] END AS [DatiVersione]
	  ,Data
  FROM [dbo].[compress_OrdiniVersioni]
