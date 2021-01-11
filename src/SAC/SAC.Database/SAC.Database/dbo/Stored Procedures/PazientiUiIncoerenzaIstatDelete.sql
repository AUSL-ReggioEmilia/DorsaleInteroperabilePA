

CREATE PROCEDURE [dbo].[PazientiUiIncoerenzaIstatDelete]
(
@Id uniqueidentifier
)
AS

BEGIN
  SET NOCOUNT OFF

  BEGIN TRY

    DELETE FROM PazientiIncoerenzaIstat
    WHERE Id = @Id

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
    ON OBJECT::[dbo].[PazientiUiIncoerenzaIstatDelete] TO [DataAccessUi]
    AS [dbo];

