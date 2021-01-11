

CREATE PROCEDURE [dbo].[IstatProvinceUiDelete]
(
	@Codice varchar(3)
)
AS

BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [IstatProvince]
    WHERE [Codice] = @Codice

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

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatProvinceUiDelete] TO [DataAccessUi]
    AS [dbo];

