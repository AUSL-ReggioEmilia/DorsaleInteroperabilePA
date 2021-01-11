
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW  [dbo].[Prestazioni]
AS
	SELECT 
		  Prestazioni.ID,
		  Prestazioni.IdRefertiBase,
		  Prestazioni.IdEsterno,
		  Prestazioni.DataInserimento,
		  Prestazioni.DataModifica,
		  Prestazioni.DataErogazione,
		  Prestazioni.PrestazioneCodice,
		  Prestazioni.PrestazioneDescrizione,
		  Prestazioni.SoundexPrestazione,
		  Prestazioni.SezioneCodice,
		  Prestazioni.SezioneDescrizione,
		  Prestazioni.SoundexSezione,
		-- Dagli attributi
		  Prestazioni.RunningNumber,
		  Prestazioni.GravitaCodice,
		  Prestazioni.GravitaDescrizione,
		  Prestazioni.Risultato,
		  Prestazioni.ValoriRiferimento,
		  Prestazioni.SezionePosizione,
		  Prestazioni.PrestazionePosizione,
		  Prestazioni.Commenti
	FROM dbo.Prestazioni2 AS Prestazioni

GO
GRANT SELECT
    ON OBJECT::[dbo].[Prestazioni] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Prestazioni] TO [DataAccessSql]
    AS [dbo];

