
CREATE PROCEDURE [ws2].[RefertoAllegatiById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
 /*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertoAllegatiById
	Restituisce la lista delle prestazioni di un referto
	Utilizza store.Allegati

*/
	SET NOCOUNT ON

	SELECT 	
		Id,
		IdRefertiBase,
		DataFile,
		MimeType,
		MimeData,
		NomeFile,
		Descrizione,
		Posizione,
		StatoCodice,
		StatoDescrizione
	FROM	
		store.Allegati
	WHERE	
		IdRefertiBase = @IdReferti

	RETURN @@ERROR
END
