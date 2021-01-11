
CREATE PROCEDURE [ws2].[RefertoPrestazioniById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN

/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertoPrestazioniById
	Restituisce la lista delle prestazioni di un referto
	Usa la vista store.Prestazioni
*/
	SET NOCOUNT ON

	SELECT	
		Id,
		IdRefertiBase,
		DataErogazione,
		SezionePosizione,
		SezioneCodice,
		SezioneDescrizione,
		PrestazionePosizione,
		PrestazioneCodice,
		PrestazioneDescrizione,
		--Lo restituisco per compatibilità, la vista non lo restituisce
		CAST(NULL AS INT) AS RunningNumber,
		GravitaCodice,
		GravitaDescrizione,
		Risultato,
		ValoriRiferimento,
		Commenti
	FROM	
		store.Prestazioni
	WHERE	
		IdRefertiBase = @IdReferti

	RETURN @@ERROR

END 


