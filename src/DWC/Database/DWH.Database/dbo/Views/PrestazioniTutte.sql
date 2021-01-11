


/*
MODIFICA ETTORE 2014-10-13: aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti
MODIFICA ETTORE 2015-03-06: nuova funzione per oscuramento
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
MODIFICA STEFANO 2015-09-23: ELIMINATA CHIAMATA A FUNCTION OSCURAMENTI									
*/
CREATE VIEW [dbo].[PrestazioniTutte]
AS
	SELECT Prestazioni.ID,
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
		  Prestazioni.DataPartizione,

		  dbo.GetPrestazioniAttributoInteger( Prestazioni.Id, Prestazioni.DataPartizione, 'RunningNumber') as RunningNumber,
      
		  Prestazioni.GravitaCodice,
		  Prestazioni.GravitaDescrizione,
		  Prestazioni.Risultato,
		  Prestazioni.ValoriRiferimento,

		  Prestazioni.SezionePosizione,
		  Prestazioni.PrestazionePosizione,

		  Prestazioni.Commenti

	FROM [store].[Prestazioni] AS Prestazioni



GO
GRANT SELECT
    ON OBJECT::[dbo].[PrestazioniTutte] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[PrestazioniTutte] TO [DataAccessSql]
    AS [dbo];

