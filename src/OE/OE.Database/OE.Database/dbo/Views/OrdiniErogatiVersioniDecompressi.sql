
CREATE VIEW [dbo].[OrdiniErogatiVersioniDecompressi]
AS
SELECT OEV.[ID]

      ,OEV.[DataInserimento]
      ,OEV.[IDTicketInserimento]
      ,T.[UserName]
      
      ,OEV.[IDOrdineErogatoTestata]
      ,OET.[IDOrdineTestata]
      ,OT.[Anno]
      ,OT.[Numero]
      
      ,OEV.[StatoOrderEntry]
      ,CASE WHEN OEV.[StatoCompressione] = 2 THEN CAST(dbo.decompress(OEV.[DatiVersioneXmlCompresso]) AS XML)
			ELSE OEV.[DatiVersione] END AS [DatiVersione]
 FROM [dbo].[OrdiniErogatiVersioni] OEV
		INNER JOIN [dbo].[OrdiniErogatiTestate] OET WITH(NOLOCK) ON OET.ID = OEV.IDOrdineErogatoTestata
	 	INNER JOIN [dbo].[OrdiniTestate] OT WITH(NOLOCK) ON OT.ID = OET.IDOrdineTestata
	 	INNER JOIN [dbo].[Tickets] T WITH(NOLOCK) ON T.ID = OEV.IDTicketInserimento
