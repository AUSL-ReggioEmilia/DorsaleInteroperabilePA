CREATE VIEW [dbo].[OrdiniErogatiVersioni]
AS 
SELECT [ID]
      ,[DataInserimento]
      ,[IDTicketInserimento]
      ,[IDOrdineErogatoTestata]
      ,[StatoOrderEntry]
      ,CASE WHEN StatoCompressione = 2 THEN CAST(dbo.decompress([DatiVersioneXmlCompresso]) AS XML)
			ELSE [DatiVersione] END AS [DatiVersione]
  FROM [dbo].[compress_OrdiniErogatiVersioni]
