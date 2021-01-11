
CREATE VIEW [dbo].[Allegati]
AS
SELECT ID
			,DataPartizione
			,IdRefertiBase
			,IdEsterno
			,DataInserimento
			,DataModifica
			,DataFile
			,MimeType
			
			,CASE WHEN MimeStatoCompressione = 2 THEN CAST(dbo.decompress(MimeDataCompresso) AS IMAGE)
				  ELSE ISNULL(MimeData, CAST(MimeDataOriginale AS IMAGE)) END AS MimeData

			,COALESCE(CONVERT(VARCHAR(255), dbo.GetAllegatiAttributo2(Id, DataPartizione, 'NomeFile')), 'NomeFile') as NomeFile
			,CONVERT(VARCHAR(255) , dbo.GetAllegatiAttributo2(Id, DataPartizione, 'Descrizione')) as Descrizione
			,dbo.GetAllegatiAttributo2Integer(Id, DataPartizione, 'Posizione') as Posizione
			,CONVERT(VARCHAR(1), dbo.GetAllegatiAttributo2(Id, DataPartizione, 'StatoCodice')) as StatoCodice
			,CONVERT(VARCHAR(50), dbo.GetAllegatiAttributo2(Id, DataPartizione, 'StatoDescrizione')) as StatoDescrizione
		
			,dbo.[GetAllegatiAttributi2Xml](ID, DataPartizione) Attributi
		
	FROM [dbo].[AllegatiBase];
