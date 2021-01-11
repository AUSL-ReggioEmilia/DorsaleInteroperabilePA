

CREATE PROCEDURE [dbo].[IstatProvinceUiInsert]
(
	@Codice varchar(3),
	@Nome varchar(64),
	@Sigla varchar(2),
	@CodiceRegione varchar(2)
)
AS

BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO [IstatProvince]
      (
      [Codice],
      [Nome],
      [Sigla],
      [CodiceRegione]
      )
     VALUES
      (
      NULLIF(@Codice, ''),
      NULLIF(@Nome, ''),
      NULLIF(@Sigla, ''),
      NULLIF(@CodiceRegione, '')
      )

    COMMIT TRANSACTION;
/*
    SELECT 
      [Codice],
      [Nome],
      [Sigla],
      [CodiceRegione]
     FROM [IstatProvince]
     WHERE [Codice] = @Codice
*/
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
    ON OBJECT::[dbo].[IstatProvinceUiInsert] TO [DataAccessUi]
    AS [dbo];

