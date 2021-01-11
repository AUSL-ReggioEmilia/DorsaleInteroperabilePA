
-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Aggiorna permessi di accesso dei vari servizi 
-- Modify date: 2018-02-22 - ETTORE: aggiunto la gestione dei campi per le "Posizioni collegate"
-- =============================================
CREATE PROCEDURE [dbo].[EntitaAccessiServiziUpdate]
(
	  @Id AS int
	, @Creazione AS bit
	, @Lettura AS bit
	, @Scrittura AS bit
	, @Eliminazione AS bit
	, @ControlloCompleto AS bit
	, @CreazioneAnonimizzazione AS bit=NULL
	, @LetturaAnonimizzazione AS bit=NULL
	, @CreazionePosizioneCollegata AS bit=NULL
	, @LetturaPosizioneCollegata AS bit=NULL
)
AS
BEGIN
	SET NOCOUNT OFF
	BEGIN TRY
		BEGIN TRANSACTION;
		---------------------------------------------------
		-- Aggiorna i dati senza controllo della concorrenza
		---------------------------------------------------
		UPDATE EntitaAccessiServizi
		SET Creazione = @Creazione
			, Lettura = @Lettura
			, Scrittura = @Scrittura
			, Eliminazione = @Eliminazione
			, ControlloCompleto = @ControlloCompleto
			, CreazioneAnonimizzazione = ISNULL(@CreazioneAnonimizzazione,0)
			, LetturaAnonimizzazione = ISNULL(@LetturaAnonimizzazione,0)
			, CreazionePosizioneCollegata = ISNULL(@CreazionePosizioneCollegata,0)
			, LetturaPosizioneCollegata = ISNULL(@LetturaPosizioneCollegata,0)
		WHERE 
			Id = @Id

		COMMIT TRANSACTION;
		
		SELECT 
			Id
			,IdServizio
			,IdEntitaAccesso
			,Creazione
			,Lettura
			,Scrittura
			,Eliminazione
			,ControlloCompleto
			,CreazioneAnonimizzazione
			,LetturaAnonimizzazione
			,CreazionePosizioneCollegata 
			,LetturaPosizioneCollegata 
		FROM EntitaAccessiServizi
		WHERE Id = @Id

		RETURN 0
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
		DECLARE @ErrorLogId INT
		EXECUTE dbo.LogError @ErrorLogId OUTPUT;
		EXECUTE RaiseErrorByIdLog @ErrorLogId 		
		RETURN @ErrorLogId
	END CATCH;

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[EntitaAccessiServiziUpdate] TO [DataAccessUi]
    AS [dbo];

