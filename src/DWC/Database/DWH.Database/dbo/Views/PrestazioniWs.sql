

/*
CREATA DA ETTORE 2015-03-02: Nuova vista dedicata da usare nei webservice
	La vista esclude i record oscurati tramite tabella degli Oscuramenti
MODIFICA SANDRO 2015-09-31: Vista di compatibilità

MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
MODIFICA STEFANO 2015-09-23: ELIMINATA CHIAMATA A FUNCTION OSCURAMENTI									
*/
CREATE VIEW [dbo].[PrestazioniWs]
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
    ON OBJECT::[dbo].[PrestazioniWs] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[PrestazioniWs] TO [DataAccessSql]
    AS [dbo];

