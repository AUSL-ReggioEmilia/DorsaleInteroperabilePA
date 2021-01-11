
CREATE PROCEDURE [dbo].[FeprRefertiSdoPrestazione]
(
	@IdPrestazioniBase as uniqueidentifier
)
AS
/*
	Restituisce i dati della prestazione passata
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
*/
	SET NOCOUNT ON
	SELECT	
		ID,
		DataErogazione,
		DataModifica,
		SezioneCodice,
		SezioneDescrizione,
		LTRIM(RTRIM(SezioneDescrizione)) + ' (' + SezioneCodice + ') ' as Sezione,
		PrestazioneCodice,
		PrestazioneDescrizione,
		GravitaCodice,
		GravitaDescrizione,
		Risultato,
		ValoriRiferimento,
		Commenti,
		SezionePosizione,
		PrestazionePosizione
	FROM	
		store.Prestazioni 
	WHERE 	
		ID = @IdPrestazioniBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiSdoPrestazione] TO [ExecuteFrontEnd]
    AS [dbo];

