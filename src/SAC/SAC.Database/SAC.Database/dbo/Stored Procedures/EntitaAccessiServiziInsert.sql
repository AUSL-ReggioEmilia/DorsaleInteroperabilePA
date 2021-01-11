
-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Inserisce un record nella tabella EntitaAccessiServizi con valori di default
-- Modify date: 2018-02-22 - ETTORE: aggiunto i nuovi campi per i diritti sulle "Posizioni Collegate"
-- =============================================
CREATE PROCEDURE [dbo].[EntitaAccessiServiziInsert]
(
	@IdEntitaAccesso AS uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF
	BEGIN TRY
		BEGIN TRANSACTION;
		---------------------------------------------------
		-- Inserisce record
		---------------------------------------------------
		INSERT INTO EntitaAccessiServizi
			( IdServizio, IdEntitaAccesso, Creazione, Lettura, Scrittura, Eliminazione, ControlloCompleto, CreazioneAnonimizzazione, LetturaAnonimizzazione, CreazionePosizioneCollegata, LetturaPosizioneCollegata)
		SELECT Id , @IdEntitaAccesso, 0, 1, 0, 0, 0 ,0, 0, 0, 0 FROM Servizi

		COMMIT TRANSACTION;
		
		SELECT Id, IdServizio, IdEntitaAccesso, Creazione, Lettura, Scrittura, Eliminazione, ControlloCompleto, CreazioneAnonimizzazione, LetturaAnonimizzazione, CreazionePosizioneCollegata, LetturaPosizioneCollegata
		FROM EntitaAccessiServizi
		WHERE IdEntitaAccesso = @IdEntitaAccesso

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
    ON OBJECT::[dbo].[EntitaAccessiServiziInsert] TO [DataAccessUi]
    AS [dbo];

