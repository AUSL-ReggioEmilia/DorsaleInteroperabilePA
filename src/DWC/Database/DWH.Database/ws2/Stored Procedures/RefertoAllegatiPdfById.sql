

CREATE PROCEDURE [ws2].[RefertoAllegatiPdfById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
 /*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RefertoAllegatiPdfById

	Restituisce gli allegati di un referto di tipo PDF
	Utilizza store.Allegati
*/
	SET NOCOUNT ON

	SELECT 	Id,
			IdRefertiBase,
			DataFile,
			MimeType,
			MimeData,
			NomeFile,
			Descrizione,
			Posizione,
			StatoCodice,
			StatoDescrizione,
			--
			-- Questo campo serve per quando sio renderizza l'HTML per segnalare
			-- che il PDF è ottenuto da rendering
			--
			CAST(0 AS BIT) AS Renderizzato
	FROM	
		store.Allegati
	WHERE	
		IdRefertiBase = @IdReferti
		AND MimeType = 'application/pdf'

	RETURN @@ERROR

END

