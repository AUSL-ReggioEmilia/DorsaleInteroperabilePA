

CREATE VIEW [store].[AllegatiBase]
AS
SELECT ID, IdRefertiBase, IdEsterno, DataInserimento, DataModifica
		, DataFile, MimeType, MimeData, DataPartizione
		, MimeDataCompresso, MimeStatoCompressione, MimeDataOriginale
	FROM dbo.AllegatiBase_History
	
	UNION ALL
	
SELECT ID, IdRefertiBase, IdEsterno, DataInserimento, DataModifica
		, DataFile, MimeType, MimeData, DataPartizione
		, MimeDataCompresso, MimeStatoCompressione, MimeDataOriginale
	FROM dbo.AllegatiBase_Recent
