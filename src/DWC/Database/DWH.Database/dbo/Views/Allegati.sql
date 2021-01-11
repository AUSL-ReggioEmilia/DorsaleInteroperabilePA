
/*
	CREATA DA ETTORE 2015-03-02: Nuova vista dedicata da usare nei webservice
								 La vista esclude i record oscurati tramite tabella degli Oscuramenti
	MODIFICA SANDRO 2015-08-19: Usa view store.Allegati che decomprime MimeData se necessario
*/
CREATE VIEW  [dbo].[Allegati]
AS
	SELECT 
		ab.ID,
		ab.IdRefertiBase,
		ab.IdEsterno,
		ab.DataInserimento,
		ab.DataModifica,
		ab.DataFile,
		ab.MimeType,
		ab.MimeData,	--Decompressione MimeData se necessario

		COALESCE(ab.NomeFile, 'NomeFile') AS NomeFile,
		ab.Descrizione,
		ab.Posizione,
		ab.StatoCodice,
		ab.StatoDescrizione
	FROM 
		[store].[Allegati] AS ab

GO
GRANT SELECT
    ON OBJECT::[dbo].[Allegati] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Allegati] TO [DataAccessSql]
    AS [dbo];

