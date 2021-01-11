

CREATE PROCEDURE [dbo].[EntitaAccessiDelete]
(
	@Id AS uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT OFF
	BEGIN TRY
		BEGIN TRANSACTION;
		---------------------------------------------------
		--  Esegue la cancellazione nella tabella EntitaAccessiServizi
		---------------------------------------------------
		EXEC EntitaAccessiServiziDelete @Id
		---------------------------------------------------
		--  Esegue la cancellazione
		---------------------------------------------------
		DELETE FROM EntitaAccessi
		WHERE Id = @Id

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
    ON OBJECT::[dbo].[EntitaAccessiDelete] TO [DataAccessUi]
    AS [dbo];

