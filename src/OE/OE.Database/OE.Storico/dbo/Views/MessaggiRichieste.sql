----------------------------------------------------

CREATE VIEW [dbo].[MessaggiRichieste]
AS 
SELECT [ID]
      ,[DataInserimento]
      ,[DataModifica]
      ,[IDTicketInserimento]
      ,[IDTicketModifica]
      ,[IDOrdineTestata]
      ,[IDSistemaRichiedente]
      ,[IDRichiestaRichiedente]
      ,CASE WHEN StatoCompressione = 2 THEN CAST(dbo.decompress([MessaggioXmlCompresso]) AS XML)
			ELSE [Messaggio] END AS [Messaggio]
      ,[Stato]
      ,[Fault]
      ,[StatoOrderEntry]
      ,[DettaglioErrore]
  FROM [dbo].[compress_MessaggiRichieste]
