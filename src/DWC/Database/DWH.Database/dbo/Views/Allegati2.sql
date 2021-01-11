

/*
	MODIFICA ETTORE 2014-10-13: aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti
	MODIFICA ETTORE 2015-03-06: nuova funzione di oscuramento
	MODIFICA SANDRO 2015-08-19: Usa view store.Allegati che decomprime MimeData se necessario
	MODIFICA STEFANO 2015-09-23: ELIMINATA CHIAMATA A FUNCTION OSCURAMENTI e CONFIDENZIALI
*/
CREATE VIEW [dbo].[Allegati2]
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
					
		ab.DataPartizione,
		COALESCE(ab.NomeFile, 'NomeFile') AS NomeFile,
		ab.Descrizione,
		ab.Posizione,
		ab.StatoCodice,
		ab.StatoDescrizione
	FROM 
		[store].[Allegati] AS ab


GO
GRANT SELECT
    ON OBJECT::[dbo].[Allegati2] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Allegati2] TO [DataAccessSql]
    AS [dbo];

