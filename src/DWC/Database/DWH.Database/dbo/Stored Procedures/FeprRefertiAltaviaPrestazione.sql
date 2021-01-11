
CREATE PROCEDURE [dbo].[FeprRefertiAltaviaPrestazione]
(
	@IdPrestazioniBase as uniqueidentifier
)
 AS
/*
	Restituisce i dati della prestazione
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
*/
	SET NOCOUNT ON
	SELECT	
		Prestazioni.ID,
		Prestazioni.DataErogazione,
		Prestazioni.DataModifica,
		Prestazioni.SezioneCodice,
		Prestazioni.SezioneDescrizione,
		LTRIM(RTRIM(Prestazioni.SezioneDescrizione)) + ' (' + Prestazioni.SezioneCodice + ') ' as Sezione,
		Prestazioni.PrestazioneCodice,
		Prestazioni.PrestazioneDescrizione,
		Prestazioni.GravitaCodice,
		Prestazioni.GravitaDescrizione,
		Prestazioni.Risultato,
		Prestazioni.ValoriRiferimento,
		Prestazioni.Commenti,
		Prestazioni.SezionePosizione,
		Prestazioni.PrestazionePosizione
	FROM	
		store.Prestazioni AS Prestazioni
	WHERE 	
		Prestazioni.ID = @IdPrestazioniBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiAltaviaPrestazione] TO [ExecuteFrontEnd]
    AS [dbo];

