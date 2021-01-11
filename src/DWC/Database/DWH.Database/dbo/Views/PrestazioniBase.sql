
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[PrestazioniBase]
AS
	SELECT ID, IdRefertiBase, IdEsterno, DataInserimento, DataModifica, DataErogazione
			, PrestazioneCodice, PrestazioneDescrizione, SoundexPrestazione
			, SezioneCodice, SezioneDescrizione, SoundexSezione
			, DataPartizione
	FROM store.PrestazioniBase

GO
GRANT SELECT
    ON OBJECT::[dbo].[PrestazioniBase] TO [DataAccessSql]
    AS [dbo];

