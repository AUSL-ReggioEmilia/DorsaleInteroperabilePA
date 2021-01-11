

CREATE PROCEDURE [dbo].[IstatComuniUiDelete]
(
	@Codice varchar(6)
)
AS

BEGIN
  SET NOCOUNT OFF

  BEGIN TRY

    DELETE FROM IstatComuni
    WHERE Codice = @Codice

    RETURN 0

  END TRY

  BEGIN CATCH
    DECLARE @ErrorLogId INT
    EXECUTE dbo.LogError @ErrorLogId OUTPUT;

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatComuniUiDelete] TO [DataAccessUi]
    AS [dbo];

