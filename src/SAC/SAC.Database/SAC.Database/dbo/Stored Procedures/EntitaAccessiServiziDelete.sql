

CREATE PROCEDURE [dbo].[EntitaAccessiServiziDelete]
(
	  @IdEntitaAccesso AS uniqueidentifier
)
AS
BEGIN
---------------------------------------------------
--  Esegue la cancellazione
---------------------------------------------------
	SET NOCOUNT OFF
	BEGIN TRY
		BEGIN TRANSACTION;
		---------------------------------------------------
		--  Esegue la cancellazione
		---------------------------------------------------
		DELETE FROM EntitaAccessiServizi
		WHERE IdEntitaAccesso = @IdEntitaAccesso
	
		COMMIT TRANSACTION;

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
    ON OBJECT::[dbo].[EntitaAccessiServiziDelete] TO [DataAccessUi]
    AS [dbo];

