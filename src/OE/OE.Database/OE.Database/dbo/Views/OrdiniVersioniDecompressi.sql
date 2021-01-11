
CREATE VIEW [dbo].[OrdiniVersioniDecompressi]
AS
SELECT OV.[ID]

      ,OV.[DataInserimento]
      ,OV.[IDTicketInserimento]
      ,T.[UserName]
      
      ,OV.[IDOrdineTestata]
      ,OT.[Anno]
      ,OT.[Numero]
      
      ,OV.[StatoOrderEntry]
      ,CASE WHEN OV.[StatoCompressione] = 2 THEN CAST(dbo.decompress(OV.[DatiVersioneXmlCompresso]) AS XML)
			ELSE OV.[DatiVersione] END AS [DatiVersione]
 FROM [dbo].[OrdiniVersioni] OV 
	 	INNER JOIN [dbo].[OrdiniTestate] OT WITH(NOLOCK) ON OT.ID = OV.IDOrdineTestata
	 	INNER JOIN [dbo].[Tickets] T WITH(NOLOCK) ON T.ID = OV.IDTicketInserimento
