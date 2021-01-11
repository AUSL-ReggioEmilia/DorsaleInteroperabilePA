



CREATE PROCEDURE [ws3].[RefertoAllegatiPdfById]
(
	@IdReferti  uniqueidentifier
)
AS
BEGIN
 /*
	CREATA DA ETTORE 2016-03-22:
		Sostituisce la dbo.Ws2RefertoAllegatiPdfById
		Restituisce gli attributi di TUTTI gli allegati PDF associati al referto @IdReferti
		Il controllo di accesso deve essere fatto sul record di testata associato, per questo motivo non c'è l'IdToken come parametro
*/
	SET NOCOUNT ON

	SELECT 	
		Id
		, IdRefertiBase
		, IdEsterno
		, NomeFile		
		, DataFile
		, Descrizione
		, Posizione
		, StatoCodice
		, StatoDescrizione
		, MimeType
		, MimeData
		--
		-- Questo campo serve per quando si renderizza l'HTML per segnalare
		-- che il PDF è ottenuto da rendering
		-- Forse questo campo si può togliere...
		--
		, CAST(0 AS BIT) AS Renderizzato
	FROM	
		store.Allegati
	WHERE	
		IdRefertiBase = @IdReferti
		AND MimeType = 'application/pdf'

END