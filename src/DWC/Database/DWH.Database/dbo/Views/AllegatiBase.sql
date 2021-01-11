
/*
MODIFICA SANDRO 2015-08-19: Vista di compatibilità

							La VISTA non è più usata per modificare i dati, per cui 
							possiamo modificarla per gestire MimeData COMPRESSO
*/
CREATE VIEW [dbo].[AllegatiBase]
AS
	SELECT ID, IdRefertiBase, IdEsterno, DataInserimento, DataModifica
		, DataFile, MimeType
		,CASE WHEN MimeStatoCompressione = 2 THEN CAST(dbo.decompress(MimeDataCompresso) AS IMAGE)
						ELSE MimeData END AS MimeData
		, DataPartizione
	FROM store.AllegatiBase



GO
GRANT SELECT
    ON OBJECT::[dbo].[AllegatiBase] TO [DataAccessSql]
    AS [dbo];

