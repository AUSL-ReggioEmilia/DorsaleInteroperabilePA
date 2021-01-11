
CREATE PROCEDURE [dbo].[EntitaAccessiUpdateInPlace]
	  @Id AS uniqueidentifier
	, @Amministratore AS bit

AS
BEGIN
	SET NOCOUNT OFF
	BEGIN TRY
		BEGIN TRANSACTION;

		UPDATE EntitaAccessi
		SET Amministratore = @Amministratore
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
    ON OBJECT::[dbo].[EntitaAccessiUpdateInPlace] TO [DataAccessUi]
    AS [dbo];

