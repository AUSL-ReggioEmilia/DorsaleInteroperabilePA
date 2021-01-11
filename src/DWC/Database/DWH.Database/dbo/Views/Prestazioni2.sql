

/*
MODIFICA ETTORE 2014-10-13: aggiunto filtro per escludere i record oscurati tramite tabella degli Oscuramenti
MODIFICA ETTORE 2015-03-06: nuova funzione di oscuramento
SANDRO 2015-09-31: Vista di compatibilità
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
MODIFICA STEFANO 2015-09-23: ELIMINATA CHIAMATA A FUNCTION OSCURAMENTI
MODIFICA SANDRO 2015-09-23: Rimosso controllo confidenziale del referto
*/
CREATE VIEW [dbo].[Prestazioni2]
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
	WHERE
		--
		-- Nascondo se le prestazioni contengono HIV
		--
			NOT Prestazioni.PrestazioneDescrizione LIKE '%HIV%'
		AND NOT Prestazioni.SezioneDescrizione LIKE '%HIV%'

GO
GRANT SELECT
    ON OBJECT::[dbo].[Prestazioni2] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Prestazioni2] TO [DataAccessSql]
    AS [dbo];

